//
//  WatchlistCoordinator.swift
//  CouchClub
//
//  Created by Ruben Dias on 27/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import Foundation
import UIKit

class WatchlistsCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init() {
        self.navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(title: "Watchlists", image: .iconAsset(.watchlists), tag: 0)
    }
    
    func start() {
        let vc = WatchlistsVC.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func showDetail(_ watchlist: Watchlist) {
        let vc = WatchlistVC.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func newWatchlist(delegate: WatchlistOperationDelegate?) {
        let child = NewWatchlistCoordinator()
        child.parentCoordinator = self
        childCoordinators.append(child)
        child.start(delegate: delegate)
    }
    
}
