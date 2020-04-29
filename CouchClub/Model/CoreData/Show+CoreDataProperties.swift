//
//  Show+CoreDataProperties.swift
//  CouchClub
//
//  Created by Ruben Dias on 28/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//
//

import Foundation
import CoreData


extension Show {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Show> {
        return NSFetchRequest<Show>(entityName: "Show")
    }

    @NSManaged public var totalSeasons: String

}
