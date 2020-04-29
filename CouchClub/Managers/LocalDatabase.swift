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
                print("Core Data: Error fetching item by id (id): \(error)")
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
                print("Core Data: Error fetching items: \(error)")
            }
        }
    }
    
}
