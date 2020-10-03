//
//  Database.swift
//  CouchClub
//
//  Created by Ruben Dias on 29/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import CoreData
import Firebase

final class LocalDatabase {
    
    static let shared = LocalDatabase()
    
    private init() {}
    
    let coreDataQueue = DispatchQueue(label: "com.rubendias.couchclub.coreDataQueue")
    let contextQueue = DispatchQueue(label: "com.rubendias.couchclub.contextQueue")
    
    // MARK: - Core Data stack
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
        
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CouchClub")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // TODO: Handle container errors
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext () {
        guard context.hasChanges else { return }
        
        contextQueue.sync { [unowned self] in
            do {
                try context.save()
            } catch {
                // TODO: Handle context saving errors
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
	
	// MARK: - General
	
	func cleanupAfterLogout() {
        deleteItems()
		deleteWatchlists()
		deleteChatrooms()
		deleteUsers()
		
		NotificationCenter.default.post(name: .watchlistsDidChange, object: nil)
		NotificationCenter.default.post(name: .chatroomsDidChange, object: nil)
	}
    
    // MARK: - Users
    
    func fetchUser(_ id: String) -> User? {
        coreDataQueue.sync {
            let fetchRequest = User.createFetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            
            do {
                let users = try context.fetch(fetchRequest)
                return users.isEmpty ? nil : users[0]
            } catch {
                let error = error as NSError
                print("Core Data: Error fetching User by id (\(id)): \(error)")
                return nil
            }
        }
    }
    
    func fetchCurrentuser() -> User {
        guard let currentUser = fetchUser(FirebaseService.shared.currentUserID) else {
            fatalError("There should always be a current user.")
        }
        return currentUser
    }
    
    func createUser(_ id: String, _ username: String = "") -> User {
        coreDataQueue.sync {
            let ub = UserBuilder(id)
            return ub.named(username).build()
        }
    }
	
	func updateUser(_ id: String, _ username: String) {
		guard let user = fetchUser(id) else { return }
		
		coreDataQueue.sync {
			user.username = username
			saveContext()
		}
		
		let userInfo = [
			"user": user
		]
		
		NotificationCenter.default.post(name: .userInfoDidChange, object: nil, userInfo: userInfo)
	}
	
    private func deleteUsers() {
		coreDataQueue.sync {
			let fetchRequest = User.createFetchRequest()
			
			do {
				let users = try context.fetch(fetchRequest)
				users.forEach { context.delete($0) }
				saveContext()
			} catch {
				let error = error as NSError
				print("Core Data: Error deleting Users: \(error)")
			}
		}
	}
    
    // MARK: - Watchlists
    
    func fetchWatchlist(_ id: UUID) -> Watchlist? {
        coreDataQueue.sync {
            let fetchRequest = Watchlist.createFetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            do {
                let watchlists = try context.fetch(fetchRequest)
                return watchlists.isEmpty ? nil : watchlists[0]
            } catch {
                let error = error as NSError
                print("Core Data: Error fetching Watchlist by id (\(id.uuidString)): \(error)")
                return nil
            }
        }
    }
    
    func fetchWatchlists() -> [Watchlist]? {
        coreDataQueue.sync {
            let fetchRequest = Watchlist.createFetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            do {
                let watchlists = try context.fetch(fetchRequest)
                return watchlists
            } catch {
                let error = error as NSError
                print("Core Data: Error fetching Watchlists: \(error)")
                return nil
            }
        }
    }
    
	func createWatchlist(id: UUID = UUID(), _ title: String, _ type: ItemType, ownedBy owner: User = LocalDatabase.shared.fetchCurrentuser()) -> Watchlist {
        coreDataQueue.sync {
            let wb = WatchlistBuilder(id: id)
            return wb.named(title)
				.ownedBy(owner)
                .ofType(type)
                .build()
        }
    }
    
    func deleteWatchlist(_ watchlist: Watchlist) {
        let watchlistItems = watchlist.items?.allObjects as? [Item]
        let itemsToDelete = watchlistItems?.filter { $0.watchlists?.count == 1 }
        deleteItems(itemsToDelete)
        
        coreDataQueue.sync {
            context.delete(watchlist)
			saveContext()
        }
    }
	
    private func deleteWatchlists() {
		guard let watchlists = fetchWatchlists() else { return }
		watchlists.forEach { deleteWatchlist($0) }
	}
    
    func addToWatchlist(_ item: Item, _ watchlist: Watchlist) {
        coreDataQueue.sync {
            watchlist.addToItems(item)
            saveContext()
        }
    }
	
	func addToWatchlist(_ items: [Item], _ watchlist: Watchlist) {
		coreDataQueue.sync {
			let itemsSet = NSSet(array: items)
			watchlist.addToItems(itemsSet)
			saveContext()
		}
	}
    
    func removeFromWatchlist(_ item: Item, _ watchlist: Watchlist) {
        coreDataQueue.sync {
            watchlist.removeFromItems(item)
            saveContext()
        }
    }
    
    // MARK: - Items
    
    func deleteItem(_ item: Item) {
        coreDataQueue.sync {
            context.delete(item)
            saveContext()
        }
    }
    
    private func deleteItems(_ items: [Item]? = nil) {
        let itemsToDelete = (items != nil ? items : fetchItems())
        
        coreDataQueue.sync {
            itemsToDelete?.forEach { context.delete($0) }
            saveContext()
        }
    }
    
    func fetchItem(_ id: String) -> Item? {
        coreDataQueue.sync {
            let fetchRequest = Item.createFetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            
            do {
                let items = try context.fetch(fetchRequest)
                return items.isEmpty ? nil : items[0]
            } catch {
                let error = error as NSError
                print("Core Data: Error fetching Item by id (\(id)): \(error)")
                return nil
            }
        }
    }
    
    func fetchItems() -> [Item]? {
        coreDataQueue.sync {
            let fetchRequest = Item.createFetchRequest()
            
            do {
                return try context.fetch(fetchRequest)
            } catch {
                let error = error as NSError
                print("Core Data: Error fetching items: \(error)")
                return nil
            }
        }
    }
    
    func toggleWatched(_ item: Item) {
        coreDataQueue.sync {
            item.watched = !item.watched
            saveContext()
        }
    }
    
    func setWatchedState(_ itemIDs: [String], completion: @escaping ()->()) {
        guard let unwatchedItems = self.fetchItems() else { completion(); return }
        
        coreDataQueue.sync {
            let watchedItems = unwatchedItems.filter { itemIDs.contains($0.id) }
            watchedItems.forEach { $0.watched = true }
            saveContext()
            completion()
        }
    }
    
    // MARK: - Chatrooms
    
    func fetchChatroom(_ id: UUID) -> Chatroom? {
        coreDataQueue.sync {
            let fetchRequest = Chatroom.createFetchRequest()
            // filtering
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            do {
                let chatrooms = try context.fetch(fetchRequest)
                return chatrooms.isEmpty ? nil : chatrooms[0]
            } catch {
                let error = error as NSError
                print("Core Data: Error fetching Chatroom by id (\(id.uuidString)): \(error)")
                return nil
            }
        }
    }
    
    func fetchChatrooms() -> [Chatroom]? {
        coreDataQueue.sync {
            let fetchRequest = Chatroom.createFetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            do {
                let chatrooms = try context.fetch(fetchRequest)
                return chatrooms
            } catch {
                let error = error as NSError
                print("Core Data: Error fetching Chatrooms: \(error)")
                return nil
            }
        }
    }
    
    func createChatroom(_ id: UUID? = nil, _ inviteCode: String? = nil, _ owner: User, _ title: String, _ type: ChatroomType, _ relatedTo: String) -> Chatroom {
        coreDataQueue.sync {
            let cb = ChatroomBuilder(id, inviteCode)
            return cb.named(title)
                .ownedBy(owner)
                .ofType(type)
                .relatedTo(relatedTo)
                .build()
        }
    }
    
    func deleteChatroom(_ chatroom: Chatroom) {
        coreDataQueue.sync {
            context.delete(chatroom)
            saveContext()
        }
    }
	
	private func deleteChatrooms() {
		guard let chatrooms = fetchChatrooms() else { return }
		chatrooms.forEach { deleteChatroom($0) }
	}
    
    // MARK: - Messages
    
    func fetchMessage(_ id: UUID) -> Message? {
        coreDataQueue.sync {
            let fetchRequest = Message.createFetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            do {
                let messages = try context.fetch(fetchRequest)
                return messages.isEmpty ? nil : messages[0]
            } catch {
                let error = error as NSError
                print("Core Data: Error fetching Message by id (\(id.uuidString)): \(error)")
                return nil
            }
        }
    }

    func createMessage(_ id: UUID? = nil, _ text: String, _ sender: User, chatroom: Chatroom, seen: Bool, _ date: Date = Date()) -> Message {
        coreDataQueue.sync {
            let mb = MessageBuilder(id)
            return mb.withText(text)
                .sentBy(sender)
                .at(date)
                .within(chatroom)
                .seen(seen)
                .build()
        }
    }
    
    func deleteMessages(_ chatroom: Chatroom) {
        coreDataQueue.sync {
            let fetchRequest = Message.createFetchRequest()
            fetchRequest.predicate = NSPredicate(format: "chatroom == %@", chatroom)
            
            do {
                let messages = try context.fetch(fetchRequest)
                messages.forEach { context.delete($0) }
                saveContext()
            } catch {
                let error = error as NSError
                print("Core Data: Error deleting Messages for Chatroom (\(chatroom.id.uuidString)): \(error)")
            }
        }
    }
    
}
