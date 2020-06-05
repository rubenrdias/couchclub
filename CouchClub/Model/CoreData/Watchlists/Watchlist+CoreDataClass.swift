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
    
    func itemsWatchedString() -> String {
        let typeString = type == ItemType.movie.rawValue ? ItemType.movie.rawValue : "show"
        guard let items = items?.allObjects as? [Item] else { return "No \(typeString)s added" }
        
        let watchedItems = items.reduce(0) { $0 + ($1.watched ? 1 : 0) }
        return "\(watchedItems) of \(items.count) \(typeString)\(items.count == 1 ? "" : "s") watched"
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
