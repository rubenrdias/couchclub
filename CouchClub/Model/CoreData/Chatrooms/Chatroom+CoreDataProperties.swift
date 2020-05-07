//
//  Chatroom+CoreDataProperties.swift
//  CouchClub
//
//  Created by Ruben Dias on 07/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//
//

import Foundation
import CoreData


extension Chatroom {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Chatroom> {
        return NSFetchRequest<Chatroom>(entityName: "Chatroom")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var subjectID: UUID
    @NSManaged public var type: String
    @NSManaged public var messages: NSSet?

}

// MARK: Generated accessors for messages
extension Chatroom {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: Message)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: Message)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}
