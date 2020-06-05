//
//  WatchlistsDataSource.swift
//  CouchClub
//
//  Created by Ruben Dias on 05/06/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class WatchlistsDataSource: NSObject {

    private var watchlists = [Watchlist]()
    weak var delegate: WatchlistsDataSourceDelegate?
    weak var collectionView: UICollectionView!
    
    var isEmpty: Bool {
        return watchlists.isEmpty
    }
    
    private var itemsPerRow: Int = 1
    private var usableWidth: CGFloat = 0
    
    convenience init(collectionView: UICollectionView, delegate: WatchlistsDataSourceDelegate? = nil) {
        self.init()
        self.collectionView = collectionView
        self.delegate = delegate
        self.setupCollectionViewLayout(collectionView.bounds.size)
    }
    
    private override init() {
        super.init()
        
        fetchData()
    }
    
    func indexOf(_ id: UUID) -> Int? {
        return watchlists.firstIndex(where: { $0.id == id })
    }
    
    func updateSeenStatus(_ item: Item) {
        var indexPathsToUpdate = [IndexPath]()
        for (index, watchlist) in watchlists.enumerated() {
            guard let items = watchlist.items?.allObjects as? [Item] else { continue }
            if items.contains(item) {
                indexPathsToUpdate.append(.init(item: index, section: 0))
            }
        }
        
        guard !indexPathsToUpdate.isEmpty else { return }
        
        DispatchQueue.main.async { [unowned self] in
            self.collectionView.reloadItems(at: indexPathsToUpdate)
        }
    }
    
    @objc func fetchData() {
        DispatchQueue.main.async { [weak self] in
            let watchlists = LocalDatabase.shared.fetchWatchlists()
            if watchlists != nil {
                self?.watchlists = watchlists!
            } else {
                self?.watchlists.removeAll()
            }

            self?.delegate?.didRefreshData()
        }
    }
    
}

extension WatchlistsDataSource: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func setupCollectionViewLayout(_ size: CGSize) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            switch UIDevice.current.orientation {
            case .portrait, .portraitUpsideDown:
                itemsPerRow = 2
            default:
                itemsPerRow = 3
            }
        } else {
            itemsPerRow = 1
        }

        collectionView.contentInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        usableWidth = size.width - 2 * 16
        updateItemSize()
    }
    
    private func updateItemSize() {
        let width: CGFloat = (usableWidth - CGFloat(itemsPerRow - 1) * 16) / CGFloat(itemsPerRow)
        let height: CGFloat = width * 11/16
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = .init(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return watchlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WatchlistCell.reuseIdentifier, for: indexPath) as! WatchlistCell
        let watchlist = watchlists[indexPath.item]
        cell.watchlist = watchlist
        cell.subtitle = watchlist.itemsWatchedString()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let watchlist = watchlists[indexPath.item]
        delegate?.didTapWatchlist(watchlist)
    }
    
}
