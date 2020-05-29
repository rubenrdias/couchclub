//
//  WatchlistCoordinator.swift
//  CouchClub
//
//  Created by Ruben Dias on 27/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class WatchlistsCoordinator: NSObject, Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    override init() {
        let navController = UINavigationController()
        navController.modalPresentationStyle = .overCurrentContext
        navController.navigationBar.prefersLargeTitles = true
        
        self.navigationController = navController
        super.init()
        
        let vc = WatchlistsVC.instantiate()
        vc.tabBarItem = UITabBarItem(title: "Watchlists", image: .iconAsset(.watchlists), tag: 0)
        vc.coordinator = self
        self.navigationController.viewControllers = [vc]
    }
    
    func showDetail(_ watchlist: Watchlist) {
        let vc = WatchlistVC.instantiate()
        vc.watchlist = watchlist
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showSearch(watchlist: Watchlist?) {
        let vc = SearchVC.instantiate()
        vc.watchlist = watchlist
        
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
    
}

extension WatchlistsCoordinator: HandlesItemDetail {
    
    func showItemDetail(_ item: Item, watchlist: Watchlist?) {
        let vc = ItemDetailVC.instantiate()
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        vc.item = item
        vc.watchlist = watchlist
        navigationController.pushViewController(vc, animated: true)
    }
    
    func didSelectItem(_ id: String) {}
    
    func didTapSeen(_ item: Item) {}
    
}
