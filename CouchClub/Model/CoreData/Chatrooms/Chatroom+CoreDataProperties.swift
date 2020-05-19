//
//  Chatroom+CoreDataProperties.swift
//  CouchClub
//
//  Created by Ruben Dias on 19/05/2020.
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
    @NSManaged public var inviteCode: String
    @NSManaged public var subjectID: String
    @NSManaged public var title: String
    @NSManaged public var type: String
    @NSManaged public var messages: NSSet?
    @NSManaged public var users: NSSet
    @NSManaged public var owner: User

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

// MARK: Generated accessors for users
extension Chatroom {

    @objc(addUsersObject:)
    @NSManaged public func addToUsers(_ value: User)

    @objc(removeUsersObject:)
    @NSManaged public func removeFromUsers(_ value: User)

    @objc(addUsers:)
    @NSManaged public func addToUsers(_ values: NSSet)

    @objc(removeUsers:)
    @NSManaged public func removeFromUsers(_ values: NSSet)

}
