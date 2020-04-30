//
//  ViewController.swift
//  CouchClub
//
//  Created by Ruben Dias on 25/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class WatchlistsVC: UICollectionViewController {
    
    private var itemsPerRow: Int = 1
    private var usableWidth: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(WatchlistCell.self, forCellWithReuseIdentifier: WatchlistCell.reuseIdentifier)
        
        setupCollectionViewLayout()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.setupCollectionViewLayout()
        }, completion: nil)
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    private func setupCollectionViewLayout() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            switch UIDevice.current.orientation {
            case .portrait, .portraitUpsideDown:
                itemsPerRow = 2
            default:
                itemsPerRow = 3
            }
            usableWidth = collectionView.bounds.width - 2 * 16
            collectionView.contentInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        } else {
            itemsPerRow = 1
            usableWidth = collectionView.bounds.width - 2 * 16
            collectionView.contentInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        }
        
        updateItemSize()
    }
    
    private func updateItemSize() {
        let width: CGFloat = (usableWidth - CGFloat(itemsPerRow - 1) * 16) / CGFloat(itemsPerRow)
        let height: CGFloat = width * 230/343
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = .init(width: width, height: height)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewWatchlistVC" {
            guard let navController = segue.destination as? UINavigationController else { return }
            guard let newWatchlistVC = navController.viewControllers.first as? NewWatchlistVC else { return }
            newWatchlistVC.delegate = self
        }
        else if segue.identifier == "WatchlistVC" {
            guard let watchlist = sender as? Watchlist else { return }
            guard let watchlistVC = segue.destination as? WatchlistVC else { return }
            watchlistVC.watchlist = watchlist
        }
    }
    
}

extension WatchlistsVC {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WatchlistCell.reuseIdentifier, for: indexPath) as! WatchlistCell
        cell.image = UIImage(named: "avengers_1")
        cell.title = "Marvel Cinematic Universe"
        cell.subtitle = "1 of 24 watched"
        return cell
    }
    
}

extension WatchlistsVC: WatchlistOperationDelegate {
    
    func didCreateWatchlist(_ id: UUID) {
        DispatchQueue.main.async { [weak self] in
            guard let watchlist = LocalDatabase.shared.fetchWatchlist(id) else { return }
            self?.performSegue(withIdentifier: "WatchlistVC", sender: watchlist)
        }
    }
    
}

