//
//  Message+CoreDataProperties.swift
//  CouchClub
//
//  Created by Ruben Dias on 09/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//
//

import Foundation
import CoreData

extension Message {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var date: Date
    @NSManaged public var id: UUID
    @NSManaged public var seen: Bool
    @NSManaged public var sender: String
    @NSManaged public var text: String
    @NSManaged public var dateSection: Date
    @NSManaged public var chatroom: Chatroom?

}
