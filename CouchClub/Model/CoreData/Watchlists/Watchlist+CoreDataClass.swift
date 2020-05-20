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
import UIKit

@objc(Watchlist)
public class Watchlist: NSManagedObject {

    func getThumbnail() -> UIImage? {
        guard var items = items?.allObjects as? [Item] else { return nil }
        items.sort { $0.title < $1.title }
        var thumbnail: UIImage? = nil
        
        items.forEach {
            if thumbnail == nil, let image = LocalStorage.shared.retrieve($0.id) {
                thumbnail = image
            }
        }
        
        return thumbnail
    }
    
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
        LocalDatabase.shared.saveContext()
        return self.watchlist
    }
    
}
