//
//  SearchCoordinator.swift
//  CouchClub
//
//  Created by Ruben Dias on 29/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import Foundation
import UIKit

class SearchCoordinator: Coordinator {

    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    weak var watchlist: Watchlist?
    
    init(parentCoordinator: Coordinator, watchlist: Watchlist?) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = UINavigationController()
        self.watchlist = watchlist
    }
    
    func start() {
        guard let parentNavController = parentCoordinator?.navigationController else {
            fatalError("SearchCoordinator should be started from within a parent coordinator.")
        }
        
        let vc = SearchVC.instantiate()
        vc.coordinator = self
        vc.watchlist = self.watchlist
        if #available(iOS 13.0, *) { vc.isModalInPresentation = true }
        navigationController.pushViewController(vc, animated: false)
        
        parentNavController.present(navigationController, animated: true)
    }
    
    func didFinishSearch() {
        parentCoordinator?.childDidFinish(self)
        navigationController.dismiss(animated: true)
    }
    
}

extension SearchCoordinator: HandlesItemDetail, ItemSelectionDelegate, ItemActionDelegate {
    
    func showItemDetail(_ item: Item, watchlist: Watchlist?) {
        let vc = ItemDetailVC.instantiate()
        vc.coordinator = self
        vc.item = item
        vc.watchlist = watchlist
        navigationController.pushViewController(vc, animated: true)
    }
    
    func didSelectItem(_ id: String) {}
    
    func didTapActionButton(_ item: Item) {
        if let vc = navigationController.viewControllers[0] as? NewChatroomVC {
            vc.didSelectItem(item.id)
        }
        navigationController.popViewController(animated: true)
    }
    
}
