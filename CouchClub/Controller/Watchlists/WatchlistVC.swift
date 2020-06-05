//
//  WatchlistVC.swift
//  CouchClub
//
//  Created by Ruben Dias on 30/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class WatchlistVC: UICollectionViewController, Storyboarded {
    
    weak var coordinator: WatchlistsCoordinator?
    lazy var dataSource = WatchlistItemsDataSource(watchlist: watchlist, collectionView: collectionView, delegate: self)
    
    var watchlist: Watchlist!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(watchlistItemsUpdated), name: .watchlistDidChange, object: nil)
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showSearch)),
            UIBarButtonItem(image: .iconAsset(.more), style: .plain, target: self, action: #selector(moreButtonTapped))
        ]
        
        setupCollectionView()
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        dataSource.setupCollectionViewLayout(size)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("-- DEINIT -- Watchlist VC")
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource
    }
    
    @objc private func showSearch() {
        coordinator?.showSearch(watchlist: watchlist)
    }
    
    @objc private func moreButtonTapped(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.view.tintColor = .colorAsset(.dynamicLabel)
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        ac.addAction(UIAlertAction(title: "Delete Watchlist", style: .destructive) { [unowned self] _ in
            let deletionAlert = Alerts.deletionAlert(title: "Delete Watchlist?", message: "This action is irreversible.") { _ in
                DataCoordinator.shared.deleteWatchlist(self.watchlist) { error in
                    if let error = error {
                        let alert = Alerts.simpleAlert(title: "Failed", message: error.localizedDescription)
                        self.present(alert, animated: true)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            
            self.present(deletionAlert, animated: true, completion: nil)
        })
                
        ac.popoverPresentationController?.barButtonItem = sender
        present(ac, animated: true, completion: nil)
    }
    
    @objc private func watchlistItemsUpdated(_ notification: Notification) {
        guard let info = notification.userInfo else { return }
        
        if let watchlistID = info["watchlistID"] as? UUID, watchlistID == watchlist.id {
            dataSource.updateItems(reloadView: true)
        }
    }

}

extension WatchlistVC: ItemDataSourceDelegate {
    
    func didTapItem(_ item: Item) {
        coordinator?.showItemDetail(item, watchlist: watchlist)
    }
    
    func didTapItemSeen(_ item: Item) {
        DataCoordinator.shared.toggleWatched(item)
    }
    
}
