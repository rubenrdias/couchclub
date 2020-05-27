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
    
    let coreDataQueue = DispatchQueue(label: "com.couchclub.coreDataQueue")
    
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
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
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // TODO: Handle context saving errors
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
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
        guard let currentuser = fetchUser(FirebaseService.currentUserID!) else {
            fatalError("There should always be a current user.")
        }
        return currentuser
    }
    
    func createUser(_ id: String, _ username: String) -> User {
        coreDataQueue.sync {
            let ub = UserBuilder(id)
            return ub.named(username).build()
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
    
    func createWatchlist(_ title: String, _ type: ItemType) -> Watchlist {
        coreDataQueue.sync {
            let wb = WatchlistBuilder()
            return wb.named(title)
                .ofType(type)
                .build()
        }
    }
    
    func deleteWatchlist(_ watchlist: Watchlist) {
        coreDataQueue.sync {
            context.delete(watchlist)
            LocalDatabase.shared.saveContext()
        }
    }
    
    func addToWatchlist(_ item: Item, _ watchlist: Watchlist) {
        coreDataQueue.sync {
            watchlist.addToItems(item)
            LocalDatabase.shared.saveContext()
        }
    }
    
    func removeFromWatchlist(_ item: Item, _ watchlist: Watchlist) {
        coreDataQueue.sync {
            watchlist.removeFromItems(item)
            LocalDatabase.shared.saveContext()
        }
    }
    
    // MARK: - Items
    
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
    
    func toggleWatched(_ item: Item) {
        coreDataQueue.sync {
            item.watched = !item.watched
            LocalDatabase.shared.saveContext()
        }
    }
    
    func createMovie(from )
    
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
            LocalDatabase.shared.saveContext()
        }
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
                LocalDatabase.shared.saveContext()
            } catch {
                let error = error as NSError
                print("Core Data: Error deleting Messages for Chatroom (\(chatroom.id.uuidString)): \(error)")
            }
        }
    }
    
}
