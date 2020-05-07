//
//  Message+CoreDataClass.swift
//  CouchClub
//
//  Created by Ruben Dias on 07/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Message)
public class Message: NSManagedObject {

}

class MessageBuilder {
    
    var message: Message
    
    init(_ id: UUID? = nil) {
        self.message = Message(context: context)
        self.message.id = id == nil ? UUID() : id!
    }
    
    func within(_ chatroom: Chatroom) -> MessageBuilder {
        self.message.chatroom = chatroom
        return self
    }
    
    func withText(_ text: String) -> MessageBuilder {
        self.message.text = text
        return self
    }
    
    func sentBy(_ sender: String) -> MessageBuilder {
        self.message.sender = sender
        return self
    }
    
    func at(_ date: Date) -> MessageBuilder {
        self.message.date = date
        return self
    }
    
    func markedAs(_ seen: Bool) -> MessageBuilder {
        self.message.seen = seen
        return self
    }
    
    func build() -> Message {
        ad.saveContext()
        return self.message
    }
    
}
