//
//  WatchlistVC.swift
//  CouchClub
//
//  Created by Ruben Dias on 30/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class WatchlistVC: UICollectionViewController {
    
    private var itemsPerRow: Int = 1
    private var usableWidth: CGFloat = 0
    
    var watchlist: Watchlist! {
        didSet {
            if let items = watchlist.items?.allObjects as? [Item] {
                watchlistItems = items.sorted { $0.title < $1.title }
            }
        }
    }
    var watchlistItems = [Item]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(watchlistItemsUpdated), name: .watchlistDidChange, object: nil)
        
        collectionView.register(TextCVCell.self, forCellWithReuseIdentifier: TextCVCell.reuseIdentifier)
        
        
        setupCollectionViewLayout()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("-- DEINIT -- Watchlist VC")
    }
    
    @IBAction func moreButtonTapped(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.view.tintColor = UIColor.colorAsset(.dynamicLabel)
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        ac.addAction(UIAlertAction(title: "Delete Watchlist", style: .destructive) { [weak self] _ in
            let deletionAlert = Alerts.deletionAlert(title: "Delete Watchlist?", message: "This action is irreversible.") { _ in
                guard let watchlist = self?.watchlist else { return }
                DataCoordinator.shared.deleteWatchlist(watchlist) { error in
                    if let error = error {
                        // TODO: handle errors
                        print("Error when deleting watchlist: ", error.localizedDescription)
                    } else {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
            
            self?.present(deletionAlert, animated: true, completion: nil)
        })
                
        ac.popoverPresentationController?.barButtonItem = sender
        present(ac, animated: true, completion: nil)
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
    }
    
    @objc private func watchlistItemsUpdated(_ notification: Notification) {
        guard let info = notification.userInfo else { return }
        
        if let watchlistID = info["watchlistID"] as? UUID, watchlistID == watchlist.id {
            if let items = watchlist.items?.allObjects as? [Item] {
                watchlistItems = items.sorted { $0.title < $1.title }
                
//                DispatchQueue.main.async { [weak self] in
//                    self?.collectionView.reloadSections([2])
//                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchVC" {
            guard let navController = segue.destination as? UINavigationController else { return }
            guard let searchVC = navController.viewControllers.first as? SearchVC else { return }
            searchVC.watchlist = watchlist
        }
    }

}

extension WatchlistVC: UICollectionViewDelegateFlowLayout {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextCVCell.reuseIdentifier, for: indexPath) as! TextCVCell
        cell.text = watchlist.title
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            let size = CGSize(width: usableWidth, height: 80)
            let attributes = [NSAttributedString.Key.font: UIFont.translatedFont(for: .title2, .semibold)]
            let estimatedFrame = NSString(string: watchlist.title).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            
            return .init(width: usableWidth, height: estimatedFrame.height)
        } else {
            let width: CGFloat = (usableWidth - CGFloat(itemsPerRow - 1) * 16) / CGFloat(itemsPerRow)
            let height: CGFloat = width * 230/343
            
            return .init(width: width, height: height)
        }
    }
    
}
