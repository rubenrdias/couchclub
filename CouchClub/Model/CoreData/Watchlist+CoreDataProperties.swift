//
//  Watchlist+CoreDataProperties.swift
//  CouchClub
//
//  Created by Ruben Dias on 30/04/2020.
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

}
