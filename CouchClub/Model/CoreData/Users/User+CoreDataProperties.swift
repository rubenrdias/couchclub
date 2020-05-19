//
//  User+CoreDataProperties.swift
//  CouchClub
//
//  Created by Ruben Dias on 19/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var id: String
    @NSManaged public var username: String
    @NSManaged public var chatrooms: NSSet?
    @NSManaged public var messages: NSSet?
    @NSManaged public var ownedChatrooms: NSSet?

}

// MARK: Generated accessors for chatrooms
extension User {

    @objc(addChatroomsObject:)
    @NSManaged public func addToChatrooms(_ value: Chatroom)

    @objc(removeChatroomsObject:)
    @NSManaged public func removeFromChatrooms(_ value: Chatroom)

    @objc(addChatrooms:)
    @NSManaged public func addToChatrooms(_ values: NSSet)

    @objc(removeChatrooms:)
    @NSManaged public func removeFromChatrooms(_ values: NSSet)

}

// MARK: Generated accessors for messages
extension User {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: Message)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: Message)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}

// MARK: Generated accessors for ownedChatrooms
extension User {

    @objc(addOwnedChatroomsObject:)
    @NSManaged public func addToOwnedChatrooms(_ value: Chatroom)

    @objc(removeOwnedChatroomsObject:)
    @NSManaged public func removeFromOwnedChatrooms(_ value: Chatroom)

    @objc(addOwnedChatrooms:)
    @NSManaged public func addToOwnedChatrooms(_ values: NSSet)

    @objc(removeOwnedChatrooms:)
    @NSManaged public func removeFromOwnedChatrooms(_ values: NSSet)

}
