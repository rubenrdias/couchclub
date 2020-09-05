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

	var lastMessage: Message? {
		get {
			guard let messages = messages?.allObjects as? [Message], !messages.isEmpty else { return nil }
			let sortedMessages = messages.sorted { $0.date > $1.date }
			return sortedMessages.first
		}
	}
	
}

class ChatroomBuilder {
    
    var chatroom: Chatroom
    
    init(_ id: UUID? = nil, _ inviteCode: String? = nil) {
        self.chatroom = Chatroom(context: context)
        self.chatroom.id = id == nil ? UUID() : id!
        self.chatroom.inviteCode = inviteCode == nil ? generateInviteCode() : inviteCode!
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
    
    private func generateInviteCode() -> String {
        return String(UUID().uuidString.prefix(8))
    }
    
    func build() -> Chatroom {
        LocalDatabase.shared.saveContext()
        return self.chatroom
    }
    
}
