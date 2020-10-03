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

}

extension WatchlistVC: ItemDataSourceDelegate {
    
    func didTapItem(_ item: Item) {
        coordinator?.showItemDetail(item, watchlist: watchlist)
    }
    
    func didTapItemSeen(_ item: Item) {
        DataCoordinator.shared.toggleWatched(item) { [weak self] error in
            if error != nil {
                let ac = UIAlertController(title: "Error", message: "Something went wrong. Please try again.", preferredStyle: .alert)
                ac.view.tintColor = .colorAsset(.dynamicLabel)
                
                ac.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                        
                self?.present(ac, animated: true, completion: nil)
            }
        }
    }
    
}
