//
//  Message+CoreDataClass.swift
//  CouchClub
//
//  Created by Ruben Dias on 15/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Message)
public class Message: NSManagedObject {

}

class MessageBuilder {
    
    private var message: Message
    
    init(_ id: UUID? = nil) {
        self.message = Message(context: LocalDatabase.shared.context)
        self.message.id = id == nil ? UUID() : id!
    }
    
    func withText(_ text: String) -> MessageBuilder {
        self.message.text = text
        return self
    }
    
    func sentBy(_ sender: User) -> MessageBuilder {
        self.message.sender = sender
        return self
    }
    
    func at(_ date: Date) -> MessageBuilder {
        self.message.date = date
        let auxDateString = messageSectionFormatter.string(from: date)
        self.message.dateSection = messageSectionFormatter.date(from: auxDateString)!
        return self
    }
    
    func within(_ chatroom: Chatroom) -> MessageBuilder {
        self.message.chatroom = chatroom
        return self
    }
    
    func seen(_ seen: Bool) -> MessageBuilder {
        self.message.seen = seen
        return self
    }
    
    func build() -> Message {
        LocalDatabase.shared.saveContext()
        return self.message
    }
    
}

