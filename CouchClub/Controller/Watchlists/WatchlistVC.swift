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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let xPosition = Double(view.bounds.width / 2) - 100
        let yPosition = Double(view.bounds.height / 2) - 25
        let lbl = UILabel(frame: .init(x: xPosition, y: yPosition, width: 200, height: 50))
        lbl.text = watchlist.title
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        view.addSubview(lbl)
    }
    
    deinit {
        print("-- DEINIT -- Watchlist VC")
    }
    
    @IBAction func moreButtonTapped(_ sender: Any) {
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
        
        present(ac, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "SearchVC" {
//            guard let navController = segue.destination as? UINavigationController else { return }
//            guard let searchVC = navController.viewControllers.first as? SearchVC else { return }
//            // TODO: set watchlist
//            // TODO: set delegate
//        }
    }

}

extension WatchlistVC {
    
}
