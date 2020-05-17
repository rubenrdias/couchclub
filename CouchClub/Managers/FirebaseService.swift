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

class FirebaseService {
    
    static let shared = FirebaseService()
    static var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }
    
    private var messageListeners = [ListenerRegistration]()
    
    private init() {}
    
    // MARK: - Listen to changes in DB
    
    func configureListeners() {
        setupMessageListener()
    }
    
    private func setupMessageListener() {
        let chatrooms = LocalDatabase.shared.fetchChatrooms()
        chatrooms?.forEach { createChatroomListener($0.id) }
    }
    
    func createChatroomListener(_ id: UUID) {
        let listener = Firestore.firestore().collection("messages").whereField("chatroomID", isEqualTo: id.uuidString).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                // TODO: handle errors
                print("Firebase Firestore | Error fetching snapshots: \(error.localizedDescription)")
            }
            
            print("\(querySnapshot?.count ?? 0) message updates")
            
            querySnapshot?.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    let documentID = diff.document.documentID
                    DataCoordinator.shared.createMessage(documentID, from: diff.document.data())
                } else {
                    print("Firebase Firestore | Error: message was updated or deleted (invalid)")
                }
            }
        }
        messageListeners.append(listener)
    }
    
    private func resetMessageListeners() {
        messageListeners.forEach { $0.remove() }
        messageListeners.removeAll()
    }
    
    // MARK: - Users
    
    func createUser(_ username: String, _ email: String, _ password: String, completion: @escaping (_ uid: String?, _ error: Error?)->()) {
        // TODO: make user creation a Transaction
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Firebase Auth | Error creating user: \(error.localizedDescription)")
                // TODO: handle error
                completion(nil, error)
                return
            }
            
            Firestore.firestore().collection("users").document(result!.user.uid).setData([
                "username": username
            ]) { (error) in
                if let error = error {
                    print("Firebase Firestore | Error creating user data: \(error.localizedDescription)")
                    // TODO: retry later
                }
                
                completion(result!.user.uid, nil)
            }
        }
    }
    
    func signIn(_ email: String, _ password: String, completion: @escaping (_ error: Error?)->()) {
        Auth.auth().signIn(withEmail: email, password: password) { (_, error) in
            if let error = error {
                print("Firebase Auth | Error creating user: \(error.localizedDescription)")
                // TODO: handle error
            }
            
            completion(error)
        }
    }
    
    func signOut(completion: (_ error: Error?)->()) {
        do {
            try Auth.auth().signOut()
            completion(nil)
        } catch {
            print("Firebase Auth | Error when signing out: \(error.localizedDescription)")
            completion(error)
        }
    }
    
    func fetchUserDetails(_ id: String, completion: @escaping (_ userData: [String: Any]?, _ error: Error?)->()) {
        Firestore.firestore().collection("users").document(id).getDocument { (snapshot, error) in
            if let error = error {
                print("Firebase Firestore | Error when fetching details for user \(id): \(error.localizedDescription)")
            }
            completion(snapshot?.data(), error)
        }
    }
    
    // MARK: - Watchlists
    
    func createWatchlist(_ watchlist: Watchlist, completion: @escaping (_ error: Error?)->()) {
        let watchlistDict = [
            "owner": FirebaseService.currentUserID!,
            "title": watchlist.title,
            "type": watchlist.type
        ]
        
        Firestore.firestore().collection("watchlists").document(watchlist.id.uuidString).setData(watchlistDict) { (error) in
            if let error = error {
                print("Firebase Firestore | Error creating watchlist: \(error.localizedDescription)")
            }
            
            completion(error)
        }
    }
    
    func deleteWatchlist(_ watchlist: Watchlist, completion: @escaping (_ error: Error?)->()) {
        Firestore.firestore().collection("watchlists").document(watchlist.id.uuidString).delete { (error) in
            if let error = error {
                print("Firebase Firestore | Error deleting watchlist: \(error.localizedDescription)")
            }
            completion(error)
        }
    }
    
    func add(_ item: Item, to watchlist: Watchlist, completion: @escaping (_ error: Error?)->()) {
        Firestore.firestore().collection("watchlists").document(watchlist.id.uuidString).updateData([
            "items": FieldValue.arrayUnion([item.id])
        ]) { (error) in
            if let error = error {
                print("Firebase Firestore | Error when adding an item to watchlist: \(error.localizedDescription)")
            }
            completion(error)
        }
    }
    
    func remove(_ item: Item, from watchlist: Watchlist, completion: @escaping (_ error: Error?)->()) {
        Firestore.firestore().collection("watchlists").document(watchlist.id.uuidString).updateData([
            "items": FieldValue.arrayRemove([item.id])
        ]) { (error) in
            if let error = error {
                print("Firebase Firestore | Error when removing an item from watchlist: \(error.localizedDescription)")
            }
            completion(error)
        }
    }
    
    // MARK: - Chatrooms
    
    func createChatroom(_ chatroom: Chatroom, completion: @escaping (_ error: Error?)->()) {
        let chatroomDict = [
            "owner": FirebaseService.currentUserID!,
            "title": chatroom.title,
            "type": chatroom.type,
            "subjectID": chatroom.subjectID
        ]
        
        Firestore.firestore().collection("chatrooms").document(chatroom.id.uuidString).setData(chatroomDict) { (error) in
            if let error = error {
                print("Firebase Firestore | Error creating chatroom: \(error.localizedDescription)")
            }
            
            completion(error)
        }
    }
    
    func deleteChatroom(_ chatroom: Chatroom, completion: @escaping (_ error: Error?)->()) {
        Firestore.firestore().collection("chatrooms").document(chatroom.id.uuidString).delete { (error) in
            if let error = error {
                print("Firebase Firestore | Error deleting chatroom: \(error.localizedDescription)")
            }
            completion(error)
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
        
        Firestore.firestore().collection("messages").document(message.id.uuidString).setData(messageDict) { (error) in
            if let error = error {
                print("Firebase Firestore | Error creating message: \(error.localizedDescription)")
            }
            
            completion(error)
        }
    }
    
}
