//
//  Watchlist+CoreDataProperties.swift
//  CouchClub
//
//  Created by Ruben Dias on 06/09/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//
//

import Foundation
import CoreData


extension Watchlist {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Watchlist> {
        return NSFetchRequest<Watchlist>(entityName: "Watchlist")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var type: String
    @NSManaged public var items: NSSet?
    @NSManaged public var owner: User

}

// MARK: Generated accessors for items
extension Watchlist {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: Item)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: Item)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}
