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
    
    let coreDataQueue = DispatchQueue(label: "com.couchclub.coreDataQueue")
    
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
    
    func clearDatabase() {
        coreDataQueue.sync {
            let fetchRequest = Item.createFetchRequest()
            
            do {
                let items = try context.fetch(fetchRequest)
                for item in items {
                    context.delete(item)
                }
                ad.saveContext()
            } catch {
                let error = error as NSError
                print("Core Data: Error fetching Items: \(error)")
            }
        }
    }
    
}
