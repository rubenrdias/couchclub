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
    
    convenience init(parentCoordinator: Coordinator, searchType: ItemType) {
        self.init(parentCoordinator: parentCoordinator)
        
        let vc = createInitialVC()
        vc.searchType = searchType
        
        navigationController.viewControllers = [vc]
    }
    
    convenience init(parentCoordinator: Coordinator, watchlist: Watchlist?) {
        self.init(parentCoordinator: parentCoordinator)
        
        let vc = createInitialVC()
        vc.watchlist = watchlist
        
        navigationController.viewControllers = [vc]
    }
    
    private init(parentCoordinator: Coordinator) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = UINavigationController()
    }
    
    private func createInitialVC() -> SearchVC {
        let vc = SearchVC.instantiate()
        vc.coordinator = self
        if #available(iOS 13.0, *) { vc.isModalInPresentation = true }
        
        return vc
    }
    
    func start() {
        guard let parentNavController = parentCoordinator?.navigationController else {
            fatalError("SearchCoordinator should be started from within a parent coordinator.")
        }
        
        parentNavController.present(navigationController, animated: true)
    }
    
    func didFinishSearch() {
        if let parentCoordinator = parentCoordinator as? SelectionDelegate {
            parentCoordinator.didCancelSelection()
        } else {
            parentCoordinator?.childDidFinish(self)
            navigationController.dismiss(animated: true)
        }
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
    
    func didSelectItem(_ id: String) {
        guard let parentCoordinator = parentCoordinator as? SelectionDelegate else {
            fatalError("When SearchCoordinator is used for selection, the parentCoordinator should be a selection delegate")
        }
        parentCoordinator.didSelectItem(id)
    }
    
    func didTapActionButton(_ item: Item) {
        if let vc = navigationController.viewControllers[0] as? NewChatroomVC {
            vc.didSelectItem(item.id)
        }
        navigationController.popViewController(animated: true)
    }
    
}
