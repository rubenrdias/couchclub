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
    
    func itemsWatchedString(withDescription: Bool = true) -> String {
        let typeString = type == ItemType.movie.rawValue ? ItemType.movie.rawValue : "show"
        guard let items = items?.allObjects as? [Item], !items.isEmpty else {
            return withDescription ? "No \(typeString)s added" : "N/A"
        }
        
        let watchedItems = items.reduce(0) { $0 + ($1.watched ? 1 : 0) }
        
        var watchedString = "\(watchedItems) of \(items.count)"
        if withDescription {
            watchedString.append(" \(typeString)\(items.count == 1 ? "" : "s") watched")
        }
        
        return watchedString
    }
    
    func screenTimeString() -> String {
        guard let items = items?.allObjects as? [Item], !items.isEmpty else { return "N/A" }
        
        var timeInMinutes = 0
        items.forEach {
            if $0.runtime == "N/A" { return }
            let minutesString = $0.runtime.split(separator: " ")[0]
            if let minutes = Int(minutesString) {
                timeInMinutes += minutes
            }
        }
        
        let hours = Int(floor(Double(timeInMinutes / 60)))
        let minutes = timeInMinutes - 60 * hours
        
        if timeInMinutes == 0 {
            return "N/A"
        } else if hours == 0 {
            return "\(minutes) min"
        } else {
            var string = "\(hours) h"
            if minutes > 0 {
                string.append(" \(minutes) min")
            }
            return string
        }
    }
    
    func averageRatingString() -> String {
        guard let items = items?.allObjects as? [Item], !items.isEmpty else { return "N/A" }
        
        var globalRating: Double = 0
        items.forEach {
            if let rating = Double($0.imdbRating) {
                globalRating += rating
            }
        }
        
        globalRating = globalRating / Double(items.count)
        
        if globalRating == 0 {
            return "N/A"
        } else {
            return "\(String(format: "%.1f", globalRating))/10"
        }
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
