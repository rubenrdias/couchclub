//
//  Item+CoreDataProperties.swift
//  CouchClub
//
//  Created by Ruben Dias on 28/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var id: String
    @NSManaged public var title: String
    @NSManaged public var year: String
    @NSManaged public var rated: String
    @NSManaged public var released: String
    @NSManaged public var runtime: String
    @NSManaged public var genre: String
    @NSManaged public var director: String
    @NSManaged public var writer: String
    @NSManaged public var actors: String
    @NSManaged public var plot: String
    @NSManaged public var awards: String
    @NSManaged public var poster: String
    @NSManaged public var imdbRating: String

}
