//
//  Chatroom+CoreDataClass.swift
//  CouchClub
//
//  Created by Ruben Dias on 19/05/2020.
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
        generateInviteCode()
    }
    
    func named(_ title: String) -> ChatroomBuilder {
        self.chatroom.title = title
        return self
    }
    
    func ofType(_ type: ChatroomType) -> ChatroomBuilder {
        self.chatroom.type = type.rawValue
        return self
    }
    
    func relatedTo(_ subjectID: String) -> ChatroomBuilder {
        self.chatroom.subjectID = subjectID
        return self
    }
    
    func ownedBy(_ owner: User) -> ChatroomBuilder {
        self.chatroom.owner = owner
        return self
    }
    
    func withInviteCode(_ code: String) -> ChatroomBuilder {
        self.chatroom.inviteCode = code
        return self
    }
    
    private func generateInviteCode() {
        let code = UUID().uuidString.prefix(8)
        self.chatroom.inviteCode = String(code)
    }
    
    func build() -> Chatroom {
        ad.saveContext()
        return self.chatroom
    }
    
}
