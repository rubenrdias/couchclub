//
//  WatchlistVC.swift
//  CouchClub
//
//  Created by Ruben Dias on 30/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class WatchlistVC: UICollectionViewController {
    
    var watchlist: Watchlist!
    
    lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        return sv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(watchlistItemsUpdated), name: .watchlistDidChange, object: nil)
        
        navigationItem.title = watchlist.title
        
        setupStackView()
        updateWatchlistItems()
    }
    
    private func setupStackView() {
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
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
    
    @objc private func watchlistItemsUpdated(_ notification: Notification) {
        guard let info = notification.userInfo else { return }
        
        if let watchlistID = info["watchlistID"] as? UUID, watchlistID == watchlist.id {
            // TODO: properly refresh items
            updateWatchlistItems()
        }
    }
    
    private func updateWatchlistItems() {
        stackView.arrangedSubviews.forEach{ $0.removeFromSuperview() }
        
        if let items = watchlist.items?.allObjects as? [Item] {
            items.forEach {
                let lbl = UILabel()
                lbl.numberOfLines = 0
                lbl.text = $0.title
                lbl.textAlignment = .center
                stackView.addArrangedSubview(lbl)
            }
            stackView.sizeToFit()
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

extension WatchlistVC {
    
}
