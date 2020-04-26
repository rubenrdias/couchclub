//
//  Watchlist.swift
//  CouchClub
//
//  Created by Ruben Dias on 26/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class Watchlist: NSObject {
    
    let uuid: String
    let title: String
    
    init(title: String) {
        self.uuid = UUID().uuidString
        self.title = title
    }
    
}
