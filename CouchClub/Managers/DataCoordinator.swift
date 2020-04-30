//
//  DataCoordinator.swift
//  CouchClub
//
//  Created by Ruben Dias on 29/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

final class DataCoordinator {
    
    static let shared = DataCoordinator()
    
    func createWatchlist(_ title: String, _ type: ItemType, completion: @escaping (_ id: UUID?, _ error: Error?)->() ) {
        let wb = WatchlistBuilder()
        let watchlist = wb.named(title)
            .ofType(type)
            .build()
        
        // TODO: add to firebase
        // TODO: handle errors
        
        NotificationCenter.default.post(name: .watchlistsChanged, object: nil)
        completion(watchlist.id, nil)
    }
    
    func deleteWatchlist(_ watchlist: Watchlist, completion: @escaping(_ error: Error?)->()) {
        // TODO: delete from firebase
        // TODO: handle errors
        
        LocalDatabase.shared.deleteWatchlist(watchlist)
        
        NotificationCenter.default.post(name: .watchlistsChanged, object: nil)
        completion(nil)
    }
    
    func getMovie(_ id: String, completion: @escaping (Movie?)->() ) {
        NetworkService.shared.searchResult(forID: id, ofType: .movie) { searchItem in
            DispatchQueue.main.async {
                if let searchItemMovie = searchItem as? SearchItemMovie {
                    let movie = Converter.shared.toMovie(searchItemMovie)
                    completion(movie)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func getShow(_ id: String, completion: @escaping (Show?)->() ) {
        NetworkService.shared.searchResult(forID: id, ofType: .series) { searchItem in
            DispatchQueue.main.async {
                if let searchItemShow = searchItem as? SearchItemShow {
                    let show = Converter.shared.toShow(searchItemShow)
                    completion(show)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func getImage(_ itemID: String, _ url: String, completion: @escaping (UIImage?)->()) {
        if let image = LocalStorage.shared.retrieve(itemID) {
            completion(image)
            return
        }
        
        guard let url = URL(string: url) else {
            completion(nil)
            return
        }
        
        NetworkService.shared.downloadImage(url) { image in
            if let image = image {
                completion(image)
                LocalStorage.shared.store(image, named: itemID)
            }
        }
    }
    
}
