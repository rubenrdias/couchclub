//
//  Chatroom+CoreDataClass.swift
//  CouchClub
//
//  Created by Ruben Dias on 07/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Chatroom)
public class Chatroom: NSManagedObject {

}

class ChatroomBuilder {
    
    var chatroom: Chatroom
    
    init(_ id: UUID? = nil) {
        self.chatroom = Chatroom(context: context)
        self.chatroom.id = id == nil ? UUID() : id!
    }
    
    func named(_ title: String) -> ChatroomBuilder {
        self.chatroom.title = title
        return self
    }
    
    func ofType(_ type: ChatroomType) -> ChatroomBuilder {
        self.chatroom.type = type.rawValue
        return self
    }
    
    func relatedTo(_ subjectID: UUID) -> ChatroomBuilder {
        self.chatroom.subjectID = subjectID.uuidString
        return self
    }
    
    func relatedTo(_ subjectID: String) -> ChatroomBuilder {
        self.chatroom.subjectID = subjectID
        return self
    }
    
    func build() -> Chatroom {
        ad.saveContext()
        return self.chatroom
    }
    
}
