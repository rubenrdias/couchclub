//
//  Watchlist+CoreDataClass.swift
//  CouchClub
//
//  Created by Ruben Dias on 15/10/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

@objc(Watchlist)
public class Watchlist: NSManagedObject {
    
    func getThumbnail(completion: @escaping (_ thumbnail: UIImage?)->()) {
        guard var items = items?.allObjects as? [Item] else { completion(nil); return }
        items.sort{ $0.title < $1.title }
        
        guard let firstItem = items.first else { completion(nil); return }
        
        DataCoordinator.shared.fetchImage(forItem: firstItem) { image in
            completion(image)
        }
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
    
    private var watchlist: Watchlist
    
    init(id: UUID) {
        self.watchlist = Watchlist(context: LocalDatabase.shared.context)
        self.watchlist.id = id
    }
    
    func named(_ title: String) -> WatchlistBuilder {
        self.watchlist.title = title
        return self
    }
    
    func ofType(_ type: ItemType) -> WatchlistBuilder {
        self.watchlist.type = type.rawValue
        return self
    }
    
    func ownedBy(_ owner: User) -> WatchlistBuilder {
        self.watchlist.owner = owner
        self.watchlist.addToUsers(owner)
        return self
    }
    
    func sharedBy(_ users: [User]) -> WatchlistBuilder {
        self.watchlist.users = NSSet(array: users)
        return self
    }
    
    func build() -> Watchlist {
        LocalDatabase.shared.saveContext()
        return self.watchlist
    }
    
}
