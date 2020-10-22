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
    
    init(collectionView: UICollectionView, delegate: WatchlistsDataSourceDelegate? = nil) {
        super.init()
        
        self.collectionView = collectionView
        self.delegate = delegate
        
        setupObservers()
        registerViews()
        setupCollectionViewLayout(collectionView.bounds.size)
        
        refreshWatchlists()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshWatchlists), name: .watchlistsChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshWatchlist), name: .watchlistChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateSeenStatus), name: .itemWatchedStatusChanged, object: nil)
    }
    
    private func registerViews() {
        collectionView.register(WatchlistCell.self, forCellWithReuseIdentifier: WatchlistCell.reuseIdentifier)
    }
    
    func indexOf(_ id: UUID) -> Int? {
        return watchlists.firstIndex(where: { $0.id == id })
    }
    
    @objc func refreshWatchlists() {
        DispatchQueue.main.async { [weak self] in
            self?.watchlists = LocalDatabase.shared.fetchWatchlists()
            self?.collectionView.reloadData()
            self?.delegate?.didRefreshData()
        }
    }
    
    @objc func refreshWatchlist(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            guard let info = notification.userInfo else { return }
            guard let watchlistID = info["watchlistID"] as? UUID else { return }
            
            if let index = self?.indexOf(watchlistID) {
                self?.collectionView.reloadItems(at: [.init(item: index, section: 0)])
            }
        }
    }
    
    @objc private func updateSeenStatus(_ notification: Notification) {
        guard let item = notification.userInfo?["item"] as? Item else { return }
        
        var watchlistIndexPathsToUpdate = [IndexPath]()
        for (index, watchlist) in watchlists.enumerated() {
            guard let items = watchlist.items?.allObjects as? [Item] else { continue }
            if items.contains(item) {
                watchlistIndexPathsToUpdate.append(.init(item: index, section: 0))
            }
        }
        
        guard !watchlistIndexPathsToUpdate.isEmpty else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadItems(at: watchlistIndexPathsToUpdate)
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
        
        collectionView.collectionViewLayout.invalidateLayout()
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
