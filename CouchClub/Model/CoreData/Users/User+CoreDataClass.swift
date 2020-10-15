//
//  User+CoreDataClass.swift
//  CouchClub
//
//  Created by Ruben Dias on 15/10/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//
//

import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject {

}

class UserBuilder {
    
    private var user: User
    
    init(_ id: String) {
        self.user = User(context: LocalDatabase.shared.context)
        self.user.id = id
    }
    
    func named(_ username: String) -> UserBuilder {
        self.user.username = username
        return self
    }
    
    func build() -> User {
        LocalDatabase.shared.saveContext()
        return self.user
    }
    
}
