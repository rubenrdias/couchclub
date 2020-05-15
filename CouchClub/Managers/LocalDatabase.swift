//
//  Database.swift
//  CouchClub
//
//  Created by Ruben Dias on 29/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import CoreData

final class LocalDatabase {
    
    static let shared = LocalDatabase()
    
    private init() {}
    
    let coreDataQueue = DispatchQueue(label: "com.couchclub.coreDataQueue")
    
    // MARK: - Watchlists
    
    func fetchWatchlist(_ id: UUID) -> Watchlist? {
        coreDataQueue.sync {
            let fetchRequest = Watchlist.createFetchRequest()
            // filtering
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
            // sorting
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
            ad.saveContext()
        }
    }
    
    func addToWatchlist(_ item: Item, _ watchlist: Watchlist) {
        coreDataQueue.sync {
            watchlist.addToItems(item)
            ad.saveContext()
        }
    }
    
    func removeFromWatchlist(_ item: Item, _ watchlist: Watchlist) {
        coreDataQueue.sync {
            watchlist.removeFromItems(item)
            ad.saveContext()
        }
    }
    
    // MARK: - Items
    
    func fetchItem(_ id: String) -> Item? {
        coreDataQueue.sync {
            let fetchRequest = Item.createFetchRequest()
            // filtering
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
        coreDataQueue.sync { [weak item] in
            guard let item = item else { return }
            item.watched = !item.watched
            ad.saveContext()
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
            // sorting
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
    
    func createChatroom(_ title: String, _ type: ChatroomType, _ relatedTo: String) -> Chatroom {
        coreDataQueue.sync {
            let cb = ChatroomBuilder()
            return cb.named(title)
                .ofType(type)
                .relatedTo(relatedTo)
                .build()
        }
    }
    
    func deleteChatroom(_ chatroom: Chatroom) {
        coreDataQueue.sync {
            context.delete(chatroom)
            ad.saveContext()
        }
    }
    
    // MARK: - Database Reset (debugging)
    
    func clearDatabase() {
        coreDataQueue.sync {
            deleteWatchlists()
            deleteItems()
        }
    }
    
    private func deleteItems() {
        let fetchRequest = Item.createFetchRequest()
        
        do {
            let items = try context.fetch(fetchRequest)
            for item in items {
                context.delete(item)
            }
            ad.saveContext()
        } catch {
            let error = error as NSError
            print("Core Data: Error deleting Items: \(error)")
        }
    }
    
    private func deleteWatchlists() {
        let fetchRequest = Watchlist.createFetchRequest()
        
        do {
            let watchlists = try context.fetch(fetchRequest)
            for watchlist in watchlists {
                context.delete(watchlist)
            }
            ad.saveContext()
        } catch {
            let error = error as NSError
            print("Core Data: Error deleting Watchlists: \(error)")
        }
    }
    
}
