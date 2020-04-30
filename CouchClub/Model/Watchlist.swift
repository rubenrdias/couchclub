//
//  Watchlist.swift
//  CouchClub
//
//  Created by Ruben Dias on 26/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class Watchlist {
    
    let id: String
    let title: String
    let type: ItemType
    
    init(title: String, type: ItemType) {
        self.id = UUID().uuidString
        self.title = title
        self.type = type
    }
    
}
