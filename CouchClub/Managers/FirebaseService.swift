//
//  FirebaseService.swift
//  CouchClub
//
//  Created by Ruben Dias on 14/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging

class FirebaseService {
    
    struct FirebaseError {
        static let noDataForWatchlists = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to obtain watchlists data from document snapshot."])
        static let noDataForChatrooms = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to obtain chatrooms data from document snapshot."])
    }
    
    enum Listener {
        case chatroom
        case messages
    }
    
    static let shared = FirebaseService()
    private init() {}
    
    private var db = Firestore.firestore()
    
    var currentUserExists: Bool {
        return Auth.auth().currentUser != nil
    }
    
    var currentUserID: String {
        precondition(Auth.auth().currentUser != nil, "Accessing currentUserID when it is nil")
        return Auth.auth().currentUser!.uid
    }
    
    private var chatroomListeners = [(UUID, ListenerRegistration)]()
    private var messageListeners = [(UUID, ListenerRegistration)]()
    
    // MARK: - Database Changes
    
    func configureListeners() {
        guard Auth.auth().currentUser != nil else { return }
        
        configureChatroomListeners()
    }
    
    private func configureChatroomListeners() {
        let currentUser = LocalDatabase.shared.fetchCurrentuser()
        let chatrooms = LocalDatabase.shared.fetchChatrooms()
        
        chatrooms.forEach {
            if $0.owner !== currentUser {
                startChatroomListener($0.id)
            }
            startMessageListener($0.id)
        }
    }
    
    func startChatroomListener(_ id: UUID) {
        let listener = db.collection("chatrooms").document(id.uuidString).addSnapshotListener { [unowned self] (snapshot, error) in
            if let error = error {
                // TODO: handle errors
                print("Firebase Firestore | Error fetching chatroom snapshot: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot else { return }
            
            if !snapshot.exists, let chatroom = LocalDatabase.shared.fetchChatroom(id) {
                LocalDatabase.shared.deleteMessages(chatroom)
                LocalDatabase.shared.deleteChatroom(chatroom)
                self.removeListener(.messages, id)
                self.removeListener(.chatroom, id)
                
                NotificationCenter.default.post(name: .chatroomsDidChange, object: nil, userInfo: nil)
            }
        }
        chatroomListeners.append((id, listener))
    }
    
    func startMessageListener(_ id: UUID) {
        let listener = db.collection("messages").whereField("chatroomID", isEqualTo: id.uuidString).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                // TODO: handle errors
                print("Firebase Firestore | Error fetching chatroom message snapshots: \(error.localizedDescription)")
                return
            }
            
            querySnapshot?.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    let documentID = diff.document.documentID
                    DataCoordinator.shared.createMessage(documentID, from: diff.document.data())
                }
            }
        }
        messageListeners.append((id, listener))
    }
    
    func removeListener(_ listenerType: Listener, _ id: UUID) {
        switch listenerType {
        case .chatroom:
            guard let index = chatroomListeners.firstIndex(where: { $0.0 == id }) else { return }
            chatroomListeners[index].1.remove()
            chatroomListeners.remove(at: index)
        case .messages:
            guard let index = messageListeners.firstIndex(where: { $0.0 == id }) else { return }
            messageListeners[index].1.remove()
            messageListeners.remove(at: index)
        }
    }
    
    private func resetListeners() {
        chatroomListeners.forEach { $0.1.remove() }
        chatroomListeners.removeAll()
        
        messageListeners.forEach { $0.1.remove() }
        messageListeners.removeAll()
    }
    
    // MARK: - Users
    
    func createUser(_ username: String, _ email: String, _ password: String, completion: @escaping (_ uid: String?, _ error: Error?)->()) {
        Auth.auth().createUser(withEmail: email, password: password) { [unowned self] (result, error) in
            if let error = error {
                print("Firebase Auth | Error creating user: \(error.localizedDescription)")
                // TODO: handle error
                completion(nil, error)
                return
            }
            
            let userRef = self.db.collection("users").document(result!.user.uid)
            let watchedRef = self.db.collection("watched").document(result!.user.uid)
            
            self.db.runTransaction { (transaction, errorPointer) -> Any? in
                transaction.setData(["username": username], forDocument: userRef)
                transaction.setData(["items": []], forDocument: watchedRef)
                
                return nil
            } completion: { (_, error) in
                if let error = error {
                    print("Firebase Firestore | Error creating user data: \(error.localizedDescription)")
                    // TODO: retry later
                }
                
                completion(result!.user.uid, nil)
            }
        }
    }
    
    func signIn(_ email: String, _ password: String, completion: @escaping (_ error: Error?)->()) {
        Auth.auth().signIn(withEmail: email, password: password) { [unowned self] (_, error) in
            if let error = error {
                print("Firebase Auth | Error creating user: \(error.localizedDescription)")
                // TODO: handle error
				completion(error)
            } else {
				self.addDeviceFCMToken { (error) in
					completion(error)
				}
            }
        }
    }
    
    func signOut(completion: ((_ error: Error?)->())? = nil) {
        removeDeviceFCMToken()
        resetListeners()
		
        do {
            try Auth.auth().signOut()
            completion?(nil)
        } catch {
            print("Firebase Auth | Error when signing out: \(error.localizedDescription)")
			addDeviceFCMToken()
			configureListeners()
            completion?(error)
        }
    }
    
    func fetchUserDetails(_ id: String, completion: @escaping (_ userData: [String: Any]?, _ error: Error?)->()) {
        db.collection("users").document(id).getDocument { (snapshot, error) in
            if let error = error {
                print("Firebase Firestore | Error when fetching details for user \(id): \(error.localizedDescription)")
            }
            completion(snapshot?.data(), error)
        }
    }
    
    func fetchUserData(completion: @escaping (_ userData: [String: Any]?, _ error: Error?)->()) {
        var userData = [String: Any]()

        self.fetchWatchedItems { [unowned self] (watchedItems, error) in
            if let watchedItems = watchedItems {

                self.fetchWatchlists { (watchlists, error) in
                    if let watchlists = watchlists {

                        self.fetchChatrooms { (chatrooms, error) in
                            if let chatrooms = chatrooms {
                                userData["watchedItems"] = watchedItems
                                userData["items"] = self.extractItems(watchlists, chatrooms)
                                userData["users"] = self.extractUsers(watchlists, chatrooms)
                                userData["watchlists"] = watchlists
                                userData["chatrooms"] = chatrooms

                                completion(userData, nil)
                            } else { completion(nil, error) }
                        }
                    } else { completion(nil, error) }
                }
            } else { completion(nil, error) }
        }
    }
    
    // Returns an array of item IDs, organized by Item Type
    // Example: [("movie", "tt0903624"), ("movie", "tt1170358"), ("series", "tt0108778")]
    private func extractItems(_ watchlists: [[String: Any]], _ chatrooms: [[String: Any]]) -> [(String, String)] {
        var items = [(String, String)]()
        
        watchlists.forEach {
            guard let type = ItemType(rawValue: ($0["type"] as? String) ?? "") else { return }
            
            if let watchlistItems = $0["items"] as? [String] {
                let watchlistItemTupples = watchlistItems.map { (type.rawValue, $0) }
                items.append(contentsOf: watchlistItemTupples)
            }
        }
        
        chatrooms.forEach {
            guard let type = $0["type"] as? String, type != ChatroomType.watchlist.rawValue else { return }
            
            if let item = $0["subjectID"] as? String {
                items.append((type, item))
            }
        }
        
        return items.compactMap { $0 }
    }
    
    private func extractUsers(_ watchlists: [[String: Any]], _ chatrooms: [[String: Any]]) -> [String] {
        var users = [String]()
        
        watchlists.forEach {
            guard let watchlistUsers = $0["users"] as? [String] else { return }
            users.append(contentsOf: watchlistUsers)
        }
        
        chatrooms.forEach {
            guard let watchlistUsers = $0["users"] as? [String] else { return }
            users.append(contentsOf: watchlistUsers)
        }
        
        return users.compactMap { $0 }
    }
    
	func addDeviceFCMToken(completion: ((_ error: Error?)->())? = nil) {
        guard let token = Messaging.messaging().fcmToken else { return }
        
        db.collection("users").document(self.currentUserID).updateData([
            "devices": FieldValue.arrayUnion([token])
        ]) { (error) in
            if let error = error {
                print("Firebase Messaging | Error when adding device token to devices list: \(error.localizedDescription)")
            }
			completion?(error)
        }
    }
    
    func removeDeviceFCMToken(completion: ((_ error: Error?)->())? = nil) {
        guard currentUserExists else { return }
        guard let token = Messaging.messaging().fcmToken else { return }
        
        db.collection("users").document(self.currentUserID).updateData([
            "devices": FieldValue.arrayRemove([token])
        ]) { (error) in
            if let error = error {
                print("Firebase Messaging | Error when removing device token to devices list: \(error.localizedDescription)")
            }
			completion?(error)
        }
    }
    
    // MARK: - Watchlists
    
    func createWatchlist(_ watchlist: Watchlist, completion: @escaping (_ error: Error?)->()) {
        let watchlistDict: [String: Any] = [
            "owner": self.currentUserID,
            "title": watchlist.title,
            "type": watchlist.type,
            "users": FieldValue.arrayUnion([self.currentUserID])
        ]
        
        db.collection("watchlists").document(watchlist.id.uuidString).setData(watchlistDict) { (error) in
            if let error = error {
                print("Firebase Firestore | Error creating watchlist: \(error.localizedDescription)")
            }
            
            completion(error)
        }
    }
    
    func deleteWatchlist(_ watchlist: Watchlist, completion: @escaping (_ error: Error?)->()) {
        db.collection("watchlists").document(watchlist.id.uuidString).delete { (error) in
            if let error = error {
                print("Firebase Firestore | Error deleting watchlist: \(error.localizedDescription)")
            }
            completion(error)
        }
    }
    
    func fetchWatchlistDetails(_ id: String, completion: @escaping (_ chatroomData: [String: Any]?, _ error: Error?) -> ()) {
        db.collection("watchlists").document(id).getDocument { (snapshot, error) in
            if let error = error {
                print("Firebase Firestore | Error fetching watchlist data for id \(id): \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard var watchlistData = snapshot?.data() else {
                completion(nil, nil)
                return
            }
            
            watchlistData["id"] = id
            
            completion(watchlistData, nil)
        }
    }
	
	func fetchWatchlists(completion: @escaping (_ watchlistsData: [[String: Any]]?, _ error: Error?)->()) {
		db.collection("watchlists").whereField("users", arrayContains: self.currentUserID).getDocuments { (snapshot, error) in
            if let error = error {
                print("Firebase Firestore | Error fetching watchlists for current user: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("Firebase Firestore | Could not find documents from watchlists snapshot for current user.")
                completion(nil, FirebaseError.noDataForWatchlists)
                return
            }
            
            let watchlistsData: [[String: Any]] = documents.map {
                var data = $0.data()
                data["id"] = $0.documentID
                return data
            }
            
            completion(watchlistsData, nil)
		}
	}
    
    func add(_ item: Item, to watchlist: Watchlist, completion: @escaping (_ error: Error?)->()) {
        db.collection("watchlists").document(watchlist.id.uuidString).updateData([
            "items": FieldValue.arrayUnion([item.id])
        ]) { error in
            if let error = error {
                print("Firebase Firestore | Error when adding an item to watchlist: \(error.localizedDescription)")
            }
            completion(error)
        }
    }
    
    func remove(_ item: Item, from watchlist: Watchlist, completion: @escaping (_ error: Error?)->()) {
        db.collection("watchlists").document(watchlist.id.uuidString).updateData([
            "items": FieldValue.arrayRemove([item.id])
        ]) { error in
            if let error = error {
                print("Firebase Firestore | Error when removing an item from watchlist: \(error.localizedDescription)")
            }
            completion(error)
        }
    }
    
    func toggleWatched(_ item: Item, completion: @escaping (_ error: Error?)->()) {
        db.collection("watched").document(self.currentUserID).updateData([
            "items": item.watched ? FieldValue.arrayRemove([item.id]) : FieldValue.arrayUnion([item.id])
        ]) { error in
            if let error = error {
                print("Firebase Firestore | Error when setting an item's watched state: \(error.localizedDescription)")
            }
            completion(error)
        }
    }
    
    func fetchWatchedItems(completion: @escaping (_ items: [String]?, _ error: Error?)->()) {
        db.collection("watched").document(self.currentUserID).getDocument { (snapshot, error) in
            if let error = error {
                print("Firebase Firestore | Error fetching watched items for current user: \(error.localizedDescription)")
                completion([], error)
                return
            }
            
            let items = snapshot?.get("items") as? [String] ?? []
            completion(items, nil)
        }
    }
    
    // MARK: - Chatrooms
    
    func createChatroom(_ chatroom: Chatroom, completion: @escaping (_ error: Error?)->()) {
        let chatroomDict: [String: Any] = [
            "owner": chatroom.owner.id,
            "title": chatroom.title,
            "type": chatroom.type,
            "subjectID": chatroom.subjectID,
            "inviteCode": chatroom.inviteCode,
            "users": FieldValue.arrayUnion([chatroom.owner.id])
        ]
        
        db.collection("chatrooms").document(chatroom.id.uuidString).setData(chatroomDict) { (error) in
            if let error = error {
                print("Firebase Firestore | Error creating chatroom: \(error.localizedDescription)")
            }
            
            completion(error)
        }
    }
    
    func joinChatroom(_ chatroom: Chatroom, completion: @escaping(_ error: Error?)->()) {
        let currentUser = LocalDatabase.shared.fetchCurrentuser()
        
        let chatroomRef = db.collection("chatrooms").document(chatroom.id.uuidString)
        var watchlistRef: DocumentReference?
        
        if chatroom.type == ChatroomType.watchlist.rawValue {
            watchlistRef = db.collection("watchlists").document(chatroom.subjectID)
        }
        
        db.runTransaction { (transaction, errorPointer) -> Any? in
            transaction.updateData(["users": FieldValue.arrayUnion([currentUser.id])], forDocument: chatroomRef)
            
            if let watchlistRef = watchlistRef {
                transaction.updateData(["users": FieldValue.arrayUnion([currentUser.id])], forDocument: watchlistRef)
            }
            
            return nil
        } completion: { (_, error) in
            completion(error)
        }
    }
    
    func leaveChatroom(_ chatroom: Chatroom, completion: @escaping(_ error: Error?)->()) {
        let currentUser = LocalDatabase.shared.fetchCurrentuser()
        
        db.collection("chatrooms").document(chatroom.id.uuidString).updateData([
            "users": FieldValue.arrayRemove([currentUser.id])
        ]) { error in
            if let error = error {
                print("Firebase Firestore | Error when removing a user from a chatroom: \(error.localizedDescription)")
            }
            completion(error)
        }
    }
    
    func deleteChatroom(_ chatroom: Chatroom, completion: @escaping (_ error: Error?)->()) {
        db.collection("chatrooms").document(chatroom.id.uuidString).delete { (error) in
            if let error = error {
                print("Firebase Firestore | Error deleting chatroom: \(error.localizedDescription)")
            }
            completion(error)
        }
    }
	
	func fetchChatrooms(completion: @escaping (_ chatroomsData: [[String: Any]]?, _ error: Error?)->()) {
		db.collection("chatrooms").whereField("users", arrayContains: self.currentUserID).getDocuments { (snapshot, error) in
			if let error = error {
				print("Firebase Firestore | Error fetching chatrooms for current user: \(error.localizedDescription)")
				completion(nil, error)
				return
			}
			
			guard let documents = snapshot?.documents else {
                completion(nil, FirebaseError.noDataForChatrooms)
				return
			}
			
			let chatroomsData: [[String: Any]] = documents.map {
				var data = $0.data()
				data["id"] = $0.documentID
				return data
			}
			completion(chatroomsData, nil)
		}
	}
    
    func fetchChatroomDetails(_ inviteCode: String, completion: @escaping (_ chatroomID: String?, _ chatroomData: [String: Any]?, _ error: Error?)->()) {
        db.collection("chatrooms").whereField("inviteCode", isEqualTo: inviteCode).getDocuments { (snapshot, error) in
            if let error = error {
                print("Firebase Firestore | Error fetching chatroom data for invite code \(inviteCode): \(error.localizedDescription)")
                completion(nil, nil, error)
                return
            }
            
            guard let documents = snapshot?.documents, !documents.isEmpty else { completion(nil, nil, nil); return }
            assert(documents.count == 1, "Invite Codes should be unique.")
            
            let chatroomID = documents[0].documentID
            let chatroomData = documents[0].data()
            completion(chatroomID, chatroomData, nil)
        }
    }
    
    // MARK: - Messages
    
    func createMessage(_ message: Message, completion: @escaping (_ error: Error?)->()) {
        let messageDict: [String : Any] = [
            "sender": message.sender.id,
            "text": message.text,
            "date": Timestamp(date: message.date),
            "chatroomID": message.chatroom.id.uuidString
        ]
        
        db.collection("messages").document(message.id.uuidString).setData(messageDict) { (error) in
            if let error = error {
                print("Firebase Firestore | Error creating message: \(error.localizedDescription)")
            }
            
            completion(error)
        }
    }
    
}
