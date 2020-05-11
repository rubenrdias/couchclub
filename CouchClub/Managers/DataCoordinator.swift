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
    
    // MARK: - Watchlists
    
    func createWatchlist(_ title: String, _ type: ItemType, completion: @escaping (_ id: UUID?, _ error: Error?)->() ) {
        let wb = WatchlistBuilder()
        let watchlist = wb.named(title)
            .ofType(type)
            .build()
        
        // TODO: add to firebase
        // TODO: handle errors
        
        NotificationCenter.default.post(name: .watchlistsDidChange, object: nil)
        completion(watchlist.id, nil)
    }
    
    func addToWatchlist(_ items: [Item], _ watchlist: Watchlist, completion: @escaping(_ error: Error?)->()) {
        // TODO: sync to firebase
        // TODO: handle errors
        
        LocalDatabase.shared.addToWatchlist(items, watchlist)
        
        let info = ["watchlistID": watchlist.id]
        NotificationCenter.default.post(name: .watchlistDidChange, object: nil, userInfo: info)
        notifyOfChatroomChanges(watchlist)
    
        completion(nil)
    }
    
    func removeFromWatchlist(_ items: [Item], _ watchlist: Watchlist, completion: @escaping(_ error: Error?)->()) {
        // TODO: sync to firebase
        // TODO: handle errors
        
        LocalDatabase.shared.removeFromWatchlist(items, watchlist)
        
        let info = ["watchlistID": watchlist.id]
        NotificationCenter.default.post(name: .watchlistDidChange, object: nil, userInfo: info)
        notifyOfChatroomChanges(watchlist)
        
        completion(nil)
    }
    
    private func notifyOfChatroomChanges(_ watchlist: Watchlist) {
        if let chatrooms = LocalDatabase.shared.fetchChatrooms() {
            let chatroomsForWatchlist = chatrooms.filter { $0.subjectID == watchlist.id.uuidString }
            chatroomsForWatchlist.forEach {
                let info = ["chatroomID": $0.id]
                NotificationCenter.default.post(name: .chatroomDidChange, object: nil, userInfo: info)
            }
        }
    }
    
    func deleteWatchlist(_ watchlist: Watchlist, completion: @escaping(_ error: Error?)->()) {
        // TODO: delete from firebase
        // TODO: delete chatroom messages firebase
        // TODO: handle errors
        
        LocalDatabase.shared.deleteWatchlist(watchlist)
        
        NotificationCenter.default.post(name: .watchlistsDidChange, object: nil)
        completion(nil)
    }
    
    // MARK: - Items
    
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
    
    func toggleWatched(_ item: Item) {
        // TODO: update in firebase
        // TODO: handle errors
        
        LocalDatabase.shared.toggleWatched(item)
        
        if let watchlists = item.watchlists?.allObjects as? [Watchlist] {
            watchlists.forEach {
                let info = ["watchlistID": $0.id]
                NotificationCenter.default.post(name: .watchlistDidChange, object: nil, userInfo: info)
            }
        }
    }
    
    // MARK: - Chatrooms
    
    func createChatroom(_ title: String, _ type: ChatroomType, _ relatedTo: UUID, completion: @escaping (_ id: UUID?, _ error: Error?)->()) {
        let cb = ChatroomBuilder()
        let chatroom = cb.named(title)
            .ofType(type)
            .relatedTo(relatedTo)
            .build()
        
        // TODO: add to firebase
        // TODO: handle errors
        
        NotificationCenter.default.post(name: .chatroomsDidChange, object: nil)
        completion(chatroom.id, nil)
    }
    
    func deleteChatroom(_ chatroom: Chatroom, completion: @escaping(_ error: Error?)->()) {
        // TODO: delete from firebase
        // TODO: handle errors
        
        LocalDatabase.shared.deleteChatroom(chatroom)
        
        NotificationCenter.default.post(name: .chatroomsDidChange, object: nil)
        completion(nil)
    }
    
    func createMessage(text: String, sender: String, chatroom: Chatroom, completion: @escaping (_ id: UUID?, _ error: Error?)->()) {
        let mb = MessageBuilder()
        let message = mb.withText(text)
            .sentBy(sender)
            .at(Date())
            .within(chatroom)
            .seen(true)
            .build()

        // TODO: add to firebase
        // TODO: handle errors

        let info = ["chatroomID": chatroom.id]
        NotificationCenter.default.post(name: .newMessage, object: nil, userInfo: info)
        completion(message.id, nil)
    }
    
    
    // MARK: - Data Download
    
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
