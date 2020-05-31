//
//  NewChatroomCoordinator.swift
//  CouchClub
//
//  Created by Ruben Dias on 28/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import Foundation
import UIKit

class NewChatroomCoordinator: Coordinator {

    weak var parentCoordinator: ChatroomsCoordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(parentCoordinator: ChatroomsCoordinator) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = UINavigationController()
    }
    
    func start() {
        guard let parentNavController = parentCoordinator?.navigationController else {
            fatalError("NewChatroomCoordinator should be started from within a parent coordinator.")
        }
        
        let vc = NewChatroomVC.instantiate()
        vc.coordinator = self
        if #available(iOS 13.0, *) { vc.isModalInPresentation = true }
        navigationController.pushViewController(vc, animated: false)
        
        parentNavController.present(navigationController, animated: true)
    }
    
    func showWatchlistSelector() {
        let vc = SelectWatchlistVC.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showItemSelector(type: ItemType) {
        let child = SearchCoordinator(parentCoordinator: self, searchType: type)
        childCoordinators.append(child)
        child.start()
    }
    
    func didFinishCreating(_ id: UUID?) {
        if let id = id {
            parentCoordinator?.chatroomCreated(id)
        }
        parentCoordinator?.childDidFinish(self)
        navigationController.dismiss(animated: true)
    }
    
    private func didFinishSelection() {
        if let child = childCoordinators.first as? SearchCoordinator {
            childDidFinish(child)
            navigationController.dismiss(animated: true)
        } else {
            navigationController.popViewController(animated: true)
        }
    }
    
}

extension NewChatroomCoordinator: SelectionDelegate {
    
    func didSelectWatchlist(_ id: UUID) {
        guard let vc = navigationController.viewControllers[0] as? NewChatroomVC else { return }
        vc.didSelectWatchlist(id)
        didFinishSelection()
    }
    
    func didSelectItem(_ id: String) {
        guard let vc = navigationController.viewControllers[0] as? NewChatroomVC else { return }
        vc.didSelectItem(id)
        didFinishSelection()
    }
    
    func didCancelSelection() {
        guard let vc = navigationController.viewControllers[0] as? NewChatroomVC else { return }
        vc.didCancelSelection()
        didFinishSelection()
    }
    
}
