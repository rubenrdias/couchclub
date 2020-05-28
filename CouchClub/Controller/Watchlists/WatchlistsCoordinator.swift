//
//  WatchlistCoordinator.swift
//  CouchClub
//
//  Created by Ruben Dias on 27/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import Foundation
import UIKit

class WatchlistsCoordinator: NSObject, Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    override init() {
        let navController = UINavigationController()
        navController.modalPresentationStyle = .overCurrentContext
        navController.tabBarItem = UITabBarItem(title: "Watchlists", image: .iconAsset(.watchlists), tag: 0)
        
        self.navigationController = navController
        super.init()
    }
    
    func start() {
        let vc = WatchlistsVC.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func showDetail(_ watchlist: Watchlist) {
        let vc = WatchlistVC.instantiate()
        vc.coordinator = self
        vc.watchlist = watchlist
        navigationController.pushViewController(vc, animated: true)
    }
    
    func newWatchlist() {
        let child = NewWatchlistCoordinator(parentCoordinator: self)
        childCoordinators.append(child)
        child.start()
    }
    
    func watchlistCreated(_ id: UUID) {
        guard let vc = navigationController.viewControllers[0] as? WatchlistsVC else { return }
        vc.didCreateWatchlist(id)
    }
    
    func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
    
}
