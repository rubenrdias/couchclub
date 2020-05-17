//
//  DataCoordinator.swift
//  CouchClub
//
//  Created by Ruben Dias on 29/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import FirebaseFirestore

final class DataCoordinator {
    
    static let shared = DataCoordinator()
    
    private init() {}
    
    // MARK: - users
    
    func createUser(_ username: String, _ email: String, _ password: String, completion: @escaping (_ error: Error?)->()) {
        FirebaseService.shared.createUser(username, email, password) { [unowned self] (uid, error) in
            if let error = error {
                completion(error)
            } else {
                self.createLocalUser(FirebaseService.currentUserID!) { (_, error) in
                    if error != nil {
                        FirebaseService.shared.signOut { (error) in
                            if error != nil { fatalError("Can't go on with user signed in, when no local user can be created.") }
                        }
                    }
                    completion(error)
                }
            }
        }
    }
    
    func signIn(_ email: String, _ password: String, completion: @escaping (_ error: Error?)->()) {
        FirebaseService.shared.signIn(email, password) { [unowned self] (error) in
            if let error = error {
                completion(error)
            } else if LocalDatabase.shared.fetchUser(FirebaseService.currentUserID!) == nil {
                self.createLocalUser(FirebaseService.currentUserID!) { (_, error) in
                    if error != nil {
                        FirebaseService.shared.signOut { (error) in
                            if error != nil { fatalError("Can't go on with user signed in, when no local user can be created.") }
                        }
                    }
                    completion(error)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func createLocalUser(_ id: String, completion: @escaping (_ user: User?, _ error: Error?)->()) {
        FirebaseService.shared.fetchUserDetails(id) { (userData, error) in
            if let error = error {
                completion(nil, error)
            } else {
                guard let userData = userData else { return }
                guard let username = userData["username"] as? String else { return }
                
                let user = LocalDatabase.shared.createUser(id, username)
                completion(user, nil)
            }
        }
    }
    
    func createCurrentUserObject() {
        guard let currentUserID = FirebaseService.currentUserID else { return }
        
        if LocalDatabase.shared.fetchUser(currentUserID) == nil {
            createLocalUser(currentUserID) { (_, error) in
                if error != nil { fatalError("When logged in, a user object for Current User must exist") }
            }
        }
    }
    
    // MARK: - Watchlists
    
    func createWatchlist(_ title: String, _ type: ItemType, completion: @escaping (_ id: UUID?, _ error: Error?)->() ) {
        let watchlist = LocalDatabase.shared.createWatchlist(title, type)
        
        FirebaseService.shared.createWatchlist(watchlist) { (error) in
            if let error = error {
                LocalDatabase.shared.deleteWatchlist(watchlist)
                completion(nil, error)
            } else {
                FirebaseService.shared.createChatroomListener(watchlist.id)
                NotificationCenter.default.post(name: .watchlistsDidChange, object: nil)
                completion(watchlist.id, nil)
            }
        }
    }
    
    func deleteWatchlist(_ watchlist: Watchlist, completion: @escaping(_ error: Error?)->()) {
        FirebaseService.shared.deleteWatchlist(watchlist) { (error) in
            if let error = error {
                completion(error)
            } else {
                LocalDatabase.shared.deleteWatchlist(watchlist)
                
                NotificationCenter.default.post(name: .watchlistsDidChange, object: nil)
                completion(nil)
            }
        }
    }
    
    func addToWatchlist(_ item: Item, _ watchlist: Watchlist, completion: @escaping(_ error: Error?)->()) {
        FirebaseService.shared.add(item, to: watchlist) { [unowned self] (error) in
            if let error = error {
                completion(error)
            } else {
                LocalDatabase.shared.addToWatchlist(item, watchlist)
    
                let info = ["watchlistID": watchlist.id]
                NotificationCenter.default.post(name: .watchlistDidChange, object: nil, userInfo: info)
                self.notifyOfChatroomChanges(watchlist)
            
                completion(nil)
            }
        }
    }
    
    func removeFromWatchlist(_ item: Item, _ watchlist: Watchlist, completion: @escaping(_ error: Error?)->()) {
        FirebaseService.shared.remove(item, from: watchlist) { [unowned self] (error) in
            if let error = error {
                completion(error)
            } else {
                LocalDatabase.shared.removeFromWatchlist(item, watchlist)
                
                let info = ["watchlistID": watchlist.id]
                NotificationCenter.default.post(name: .watchlistDidChange, object: nil, userInfo: info)
                self.notifyOfChatroomChanges(watchlist)
                
                completion(nil)
            }
        }
    }
    
    private func notifyOfChatroomChanges(_ watchlist: Watchlist) {
        if let chatrooms = LocalDatabase.shared.fetchChatrooms() {
            let chatroomsForWatchlist = chatrooms.filter { $0.subjectID == watchlist.id.uuidString }
            chatroomsForWatchlist.forEach {
                let info = ["chatroomID": $0.id]
                NotificationCenter.default.post(name: .chatroomDidChange, object: nil, userInfo: info)
            }
        }
    }
    
    // MARK: - Items
    
    func getMovie(_ id: String, completion: @escaping (Movie?)->() ) {
        NetworkService.shared.searchResult(forID: id, ofType: .movie) { searchItem in
            DispatchQueue.main.async {
                if let searchItemMovie = searchItem as? SearchItemMovie {
                    let movie = Converter.shared.toMovie(searchItemMovie)
                    completion(movie)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func getShow(_ id: String, completion: @escaping (Show?)->() ) {
        NetworkService.shared.searchResult(forID: id, ofType: .series) { searchItem in
            DispatchQueue.main.async {
                if let searchItemShow = searchItem as? SearchItemShow {
                    let show = Converter.shared.toShow(searchItemShow)
                    completion(show)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func toggleWatched(_ item: Item) {
        // TODO: update in firebase
        // TODO: handle errors
        
        LocalDatabase.shared.toggleWatched(item)
        
        if let watchlists = item.watchlists?.allObjects as? [Watchlist] {
            watchlists.forEach {
                let info = ["watchlistID": $0.id]
                NotificationCenter.default.post(name: .watchlistDidChange, object: nil, userInfo: info)
            }
        }
    }
    
    // MARK: - Chatrooms
    
    func createChatroom(_ title: String, _ type: ChatroomType, _ relatedTo: String, completion: @escaping (_ id: UUID?, _ error: Error?)->()) {
        let chatroom = LocalDatabase.shared.createChatroom(title, type, relatedTo)
        
        FirebaseService.shared.createChatroom(chatroom) { (error) in
            if let error = error {
                LocalDatabase.shared.deleteChatroom(chatroom)
                completion(nil, error)
            } else {
                NotificationCenter.default.post(name: .chatroomsDidChange, object: nil)
                completion(chatroom.id, nil)
            }
        }
    }
    
    func deleteChatroom(_ chatroom: Chatroom, completion: @escaping(_ error: Error?)->()) {
        FirebaseService.shared.deleteChatroom(chatroom) { (error) in
            if let error = error {
                completion(error)
            } else {
                LocalDatabase.shared.deleteChatroom(chatroom)
                
                NotificationCenter.default.post(name: .chatroomsDidChange, object: nil)
                completion(nil)
            }
        }
    }
    
    func joinChatroom(_ inviteCode: String, completion: @escaping(_ chatroom: Chatroom?, _ error: Error?)->()) {
        // TODO: fetch chatroom details
        // TODO: fetch chatroom messages
        // TODO: create local chatroom (core data)
        // TODO: create local messages (core data)
        
        // completion(chatroom, nil)
    }
    
    func createMessage(_ text: String, in chatroom: Chatroom, by senderID: String? = nil, completion: @escaping (_ error: Error?)->()) {
        let sentByCurrentUser = senderID == nil
        let sender: User
        
        if sentByCurrentUser {
            sender = LocalDatabase.shared.fetchCurrentuser()
        } else {
            guard let user = LocalDatabase.shared.fetchUser(senderID!) else { fatalError("User should exist") }
            sender = user
        }
        
        let message = LocalDatabase.shared.createMessage(nil, text, sender, chatroom: chatroom, seen: sentByCurrentUser)

        FirebaseService.shared.createMessage(message) { (error) in
            if let error = error {
                completion(error)
            } else {
                let info = ["chatroomID": chatroom.id]
                NotificationCenter.default.post(name: .newMessage, object: nil, userInfo: info)
                completion(nil)
            }
        }
    }
    
    func createMessage(_ id: String, from data: [String: Any]) {
        guard let uuid = UUID(uuidString: id) else { return }
        
        if LocalDatabase.shared.fetchMessage(uuid) == nil {
            guard let text = data["text"] as? String else { return }
            guard let timestamp = data["date"] as? Timestamp else { return }
            let date = timestamp.dateValue()
            
            guard let chatroomID = data["chatroomID"] as? String, let chatroomUUID = UUID(uuidString: chatroomID) else { return }
            guard let chatroom = LocalDatabase.shared.fetchChatroom(chatroomUUID) else { return }
            
            let dispatchGroup = DispatchGroup()
            
            var sender: User?
            guard let senderID = data["sender"] as? String else { return }
            if let user = LocalDatabase.shared.fetchUser(senderID) {
                sender = user
            } else {
                dispatchGroup.enter()
                FirebaseService.shared.fetchUserDetails(senderID) { (userData, error) in
                    // TODO: display error?
                    guard let userData = userData else { return }
                    guard let username = userData["username"] as? String else { return }
                    
                    sender = LocalDatabase.shared.createUser(senderID, username)
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.wait()
            
            if sender == nil { return }
            
            let message = LocalDatabase.shared.createMessage(uuid, text, sender!, chatroom: chatroom, seen: false, date)
            let info = ["chatroomID": message.chatroom.id]
            NotificationCenter.default.post(name: .newMessage, object: nil, userInfo: info)
        }
    }
    
    
    // MARK: - Data Download
    
    func getImage(_ itemID: String, _ url: String, completion: @escaping (UIImage?)->()) {
        if let image = LocalStorage.shared.retrieve(itemID) {
            completion(image)
            return
        }
        
        guard let url = URL(string: url) else {
            completion(nil)
            return
        }
        
        NetworkService.shared.downloadImage(url) { image in
            if let image = image {
                completion(image)
                LocalStorage.shared.store(image, named: itemID)
            }
        }
    }
    
}
