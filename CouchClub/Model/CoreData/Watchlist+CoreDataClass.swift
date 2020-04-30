//
//  Watchlist+CoreDataClass.swift
//  CouchClub
//
//  Created by Ruben Dias on 30/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Watchlist)
public class Watchlist: NSManagedObject {

}

class WatchlistBuilder {
    
    var watchlist: Watchlist
    
    init() {
        self.watchlist = Watchlist(context: context)
        watchlist.id = UUID()
    }
    
    func named(_ title: String) -> WatchlistBuilder {
        self.watchlist.title = title
        return self
    }
    
    func ofType(_ type: ItemType) -> WatchlistBuilder {
        self.watchlist.type = type.rawValue
        return self
    }
    
    func build() -> Watchlist {
        ad.saveContext()
        return self.watchlist
    }
    
}
