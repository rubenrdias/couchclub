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
    
	// MARK: - Setup
	
	func configure() {
		guard let currentUserID = FirebaseService.currentUserID else { return }
		
		if LocalDatabase.shared.fetchUser(currentUserID) == nil {
			self.createLocalUser { (_, error) in
				guard error == nil else {
					FirebaseService.shared.signOut { (error) in
						if error != nil { fatalError("Can't go on with user signed in, when no local user can be created.") }
					}
					return
				}
				
				FirebaseService.shared.configureListeners()
			}
		} else {
			FirebaseService.shared.configureListeners()
		}
	}
	
    // MARK: - Users
    
    func createUser(_ username: String, _ email: String, _ password: String, completion: @escaping (_ error: Error?)->()) {
        FirebaseService.shared.createUser(username, email, password) { [unowned self] (uid, error) in
            if let error = error {
                completion(error)
            } else {
                self.createLocalUser() { (_, error) in
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
				return
			}
			
			self.createLocalUser() { (_, error) in
				guard error == nil else {
					FirebaseService.shared.signOut { (error) in
						if error != nil { fatalError("Can't continue: user signed in, no local user could be created.") }
					}
					completion(error)
					return
				}
				
				self.restoreUserData { (error) in
					completion(error)
				}
			}
        }
    }
	
	func signOut(completion: @escaping (_ error: Error?)->()) {
		FirebaseService.shared.signOut { [unowned self] (error) in
			if let error = error {
				completion(error)
			} else {
				LocalDatabase.shared.cleanupAfterLogout()
				self.resetScreens()
				completion(nil)
			}
		}
	}
	
	private func resetScreens() {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
		appDelegate.tabBarController?.resetScreens()
	}
    
	func createLocalUser(_ id: String = FirebaseService.currentUserID!, completion: @escaping (_ user: User?, _ error: Error?)->()) {
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
    
    func fetchUser(id: String, completion: @escaping (_ user: User?, _ error: Error?)->()) {
        if let user = LocalDatabase.shared.fetchUser(id) {
            completion(user, nil)
        } else {
			let user = LocalDatabase.shared.createUser(id)
			completion(user, nil)
			
			DispatchQueue.global(qos: .userInitiated).async {
				FirebaseService.shared.fetchUserDetails(id) { (userData, error) in
					if let error = error {
						print("Firebase Firestore | Error when fetching user \(id) data: \(error.localizedDescription)")
					} else {
						guard let userData = userData else { completion(nil, nil); return }
						guard let username = userData["username"] as? String else { completion(nil, nil); return }
						
						LocalDatabase.shared.updateUser(id, username)
					}
				}
			}
        }
    }
	
	func restoreUserData(completion: @escaping (_ error: Error?)->()) {
		self.restoreWatchlists { [unowned self] (error) in
			if error != nil { completion(error); return }
			
			NotificationCenter.default.post(name: .watchlistsDidChange, object: nil, userInfo: nil)
			
			self.restoreChatrooms { (error) in
				if error != nil { completion(error); return }
				
				NotificationCenter.default.post(name: .chatroomsDidChange, object: nil, userInfo: nil)
				completion(nil)
			}
		}
		
	}
	
	func restoreWatchlists(completion: @escaping (_ error: Error?) -> ()) {
		FirebaseService.shared.fetchWatchlists { [unowned self] (watchlistsData, error) in
			guard error == nil else { completion(error); return }
			guard let watchlistsData = watchlistsData else { completion(nil);  return }
			
			let watchlistGroup = DispatchGroup()
			watchlistsData.forEach {
				guard let uuidString = $0["id"] as? String, let id = UUID(uuidString: uuidString),
					  let title = $0["title"] as? String,
					  let rawType = $0["type"] as? String, let type = ItemType(rawValue: rawType)
					  else { return }
				
				let watchlist = LocalDatabase.shared.createWatchlist(id: id, title, type)
				var watchlistRestorationError: Error?
				
				guard let items = $0["items"] as? [String] else { return }
				watchlistGroup.enter()
				
				let itemGroup = DispatchGroup()
				var itemsToAdd = [Item]()
				items.forEach {
					itemGroup.enter()
					
					switch type {
					case .movie:
						self.getMovie($0) { (movie, error) in
							guard let movie = movie else {
								watchlistRestorationError = error
								itemGroup.leave()
								return
							}
							itemsToAdd.append(movie)
							itemGroup.leave()
						}
					case .series:
						self.getShow($0) { (show, error) in
							guard let show = show else {
								watchlistRestorationError = error
								itemGroup.leave()
								return
							}
							itemsToAdd.append(show)
							itemGroup.leave()
						}
					}
				}
				
				itemGroup.wait()
				
				if watchlistRestorationError != nil {
					// TODO: mark watchlist error and retry later
				}
				
				LocalDatabase.shared.addToWatchlist(itemsToAdd, watchlist)
				watchlistGroup.leave()
			}
			
			completion(nil)
		}
	}
	
	func restoreChatrooms(completion: @escaping (_ error: Error?) -> ()) {
		FirebaseService.shared.fetchChatrooms { [unowned self] (chatroomsData, error) in
			guard error == nil else { completion(error); return }
			guard let chatroomsData = chatroomsData else { completion(nil);  return }
			
			let chatroomsGroup = DispatchGroup()
			chatroomsData.forEach {
				guard let uuidString = $0["id"] as? String else { return }
				
				chatroomsGroup.enter()
				self.createChatroom(uuidString, from: $0) { (chatroom, error) in
					if error != nil {
						// TODO: mark chatroom error and retry later
						chatroomsGroup.leave()
						return
					}
					guard let chatroom = chatroom else {
						// TODO: mark chatroom error and retry later
						chatroomsGroup.leave()
						return
					}
					
					FirebaseService.shared.startChatroomListener(chatroom.id)
					FirebaseService.shared.startMessageListener(chatroom.id)
					chatroomsGroup.leave()
				}
			}
			
			chatroomsGroup.wait()
			
			completion(nil)
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
                let info: [AnyHashable: Any] = ["chatroomID": $0.id]
                NotificationCenter.default.post(name: .chatroomDidChange, object: nil, userInfo: info)
            }
        }
    }
    
    // MARK: - Items
    
	func getMovie(_ id: String, completion: @escaping (_ movie: Movie?, _ error: Error?)->() ) {
        NetworkService.shared.searchResult(forID: id, ofType: .movie) { (searchItem, error) in
            if let searchItemMovie = searchItem as? SearchItemMovie {
                let movie = Converter.shared.toMovie(searchItemMovie)
                completion(movie, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
	func getShow(_ id: String, completion: @escaping (_ show: Show?, _ error: Error?)->() ) {
        NetworkService.shared.searchResult(forID: id, ofType: .series) { (searchItem, error) in
            if let searchItemShow = searchItem as? SearchItemShow {
                let show = Converter.shared.toShow(searchItemShow)
                completion(show, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func toggleWatched(_ item: Item) {
        // TODO: update in firebase
        // TODO: handle errors
        
        LocalDatabase.shared.toggleWatched(item)
        
        let info = ["item": item]
        NotificationCenter.default.post(name: .itemWatchedStatusChanged, object: nil, userInfo: info)
    }
    
    // MARK: - Chatrooms
    
    func createChatroom(_ title: String, _ type: ChatroomType, _ relatedTo: String, completion: @escaping (_ id: UUID?, _ error: Error?)->()) {
        let currentUser = LocalDatabase.shared.fetchCurrentuser()
        let chatroom = LocalDatabase.shared.createChatroom(nil, nil, currentUser, title, type, relatedTo)
        
        FirebaseService.shared.createChatroom(chatroom) { (error) in
            if let error = error {
                LocalDatabase.shared.deleteChatroom(chatroom)
                completion(nil, error)
            } else {
                FirebaseService.shared.startMessageListener(chatroom.id)
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
    
    func joinChatroom(_ inviteCode: String, completion: @escaping(_ chatroomID: UUID?, _ error: Error?)->()) {
        FirebaseService.shared.fetchChatroomDetails(inviteCode) { [unowned self] (chatroomID, chatroomData, error) in
            if let error = error {
                completion(nil, error)
            } else if let chatroomID = chatroomID, let chatroomData = chatroomData {
                self.createChatroom(chatroomID, from: chatroomData) { (chatroom, error) in
                    if let error = error {
                        completion(nil, error)
                        return
                    }
                    guard let chatroom = chatroom else {
                        // TODO: create error to warn the user
                        completion(nil, nil)
                        return
                    }
                    
                    FirebaseService.shared.joinChatroom(chatroom) { (error) in
                        if let error = error {
                            LocalDatabase.shared.deleteChatroom(chatroom)
                            completion(nil, error)
                        } else {
                            FirebaseService.shared.startChatroomListener(chatroom.id)
                            FirebaseService.shared.startMessageListener(chatroom.id)
                            NotificationCenter.default.post(name: .chatroomsDidChange, object: nil)
                            completion(chatroom.id, nil)
                        }
                    }
                }
            } else {
                completion(nil, nil)
            }
        }
    }
    
    func leaveChatroom(_ chatroom: Chatroom, completion: @escaping(_ error: Error?)->()) {
        FirebaseService.shared.leaveChatroom(chatroom) { (error) in
            if let error = error {
                completion(error)
            } else {
                FirebaseService.shared.removeListener(.chatroom, chatroom.id)
                LocalDatabase.shared.deleteChatroom(chatroom)
                
                NotificationCenter.default.post(name: .chatroomsDidChange, object: nil)
                completion(nil)
            }
        }
    }
    
    func createChatroom(_ id: String, from data: [String: Any], completion: @escaping (_ chatroom: Chatroom?, _ error: Error?) -> ()) {
        guard let uuid = UUID(uuidString: id),
              let inviteCode = data["inviteCode"] as? String,
              let title = data["title"] as? String,
              let subjectID = data["subjectID"] as? String,
              let ownerID = data["owner"] as? String,
              let typeString = data["type"] as? String,
              let type = ChatroomType(rawValue: typeString) else {
            // TODO: crete invalid data error
            completion(nil, nil)
            return
        }
    
        fetchUser(id: ownerID) { [unowned self] (user, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let user = user else {
                // TODO: crete invalid data error
                completion(nil, nil)
                return
            }
            
            switch type {
            case .watchlist:
                // TODO: fetch watchlist and all items
                break
            case .movie:
                self.getMovie(subjectID) { (movie, error) in
                    guard let movie = movie else {
                        completion(nil, error)
                        return
                    }
                    self.getImage(movie.id, movie.poster) { _ in
                        let chatroom = LocalDatabase.shared.createChatroom(uuid, inviteCode, user, title, type, movie.id)
                        completion(chatroom, nil)
                    }
                }
            case .show:
                self.getShow(subjectID) { (show, error) in
                    guard let show = show else {
                        completion(nil, error)
                        return
                    }
                    self.getImage(show.id, show.poster) { _ in
                        let chatroom = LocalDatabase.shared.createChatroom(uuid, inviteCode, user, title, type, show.id)
                        completion(chatroom, nil)
                    }
                }
            }
        }
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
                let info: [AnyHashable: Any] = ["chatroomID": chatroom.id]
                NotificationCenter.default.post(name: .chatroomDidChange, object: nil, userInfo: info)
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
            
            guard let senderID = data["sender"] as? String else { return }
            fetchUser(id: senderID) { (user, error) in
                if error == nil, let user = user {
                    // TODO: make the message returned discardable
                    let _ = LocalDatabase.shared.createMessage(uuid, text, user, chatroom: chatroom, seen: false, date)
                    
                    let info: [AnyHashable: Any] = ["chatroomID": chatroomUUID]
                    NotificationCenter.default.post(name: .chatroomDidChange, object: nil, userInfo: info)
                }
            }
        }
    }
    
    
    // MARK: - Data Download
    
    func getImage(_ itemID: String, _ url: String, completion: ((UIImage?)->())? = nil) {
        if let image = LocalStorage.shared.retrieve(itemID) {
            completion?(image)
            return
        }
        
        guard let url = URL(string: url) else {
            completion?(nil)
            return
        }
        
        NetworkService.shared.downloadImage(url) { image in
            if let image = image {
                LocalStorage.shared.store(image, named: itemID)
            }
            completion?(image)
        }
    }
    
}
