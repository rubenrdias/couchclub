//
//  Item+CoreDataProperties.swift
//  CouchClub
//
//  Created by Ruben Dias on 30/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var actors: String
    @NSManaged public var awards: String
    @NSManaged public var director: String
    @NSManaged public var genre: String
    @NSManaged public var id: String
    @NSManaged public var imdbRating: String
    @NSManaged public var plot: String
    @NSManaged public var poster: String
    @NSManaged public var rated: String
    @NSManaged public var released: String
    @NSManaged public var runtime: String
    @NSManaged public var title: String
    @NSManaged public var watched: Bool
    @NSManaged public var writer: String
    @NSManaged public var year: String
    @NSManaged public var watchlists: NSSet?

}

// MARK: Generated accessors for watchlists
extension Item {

    @objc(addWatchlistsObject:)
    @NSManaged public func addToWatchlists(_ value: Watchlist)

    @objc(removeWatchlistsObject:)
    @NSManaged public func removeFromWatchlists(_ value: Watchlist)

    @objc(addWatchlists:)
    @NSManaged public func addToWatchlists(_ values: NSSet)

    @objc(removeWatchlists:)
    @NSManaged public func removeFromWatchlists(_ values: NSSet)

}
