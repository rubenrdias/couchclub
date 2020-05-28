//
//  NewWatchlistCoordinator.swift
//  CouchClub
//
//  Created by Ruben Dias on 27/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import Foundation
import UIKit

class NewWatchlistCoordinator: Coordinator {

    weak var parentCoordinator: WatchlistsCoordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(parentCoordinator: WatchlistsCoordinator) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = UINavigationController()
    }
    
    func start() {
        guard let parentNavController = parentCoordinator?.navigationController else {
            fatalError("NewWatchlistCoordinator should be started from within a parent coordinator.")
        }
        
        let vc = NewWatchlistVC.instantiate()
        vc.coordinator = self
        if #available(iOS 13.0, *) { vc.isModalInPresentation = true }
        navigationController.pushViewController(vc, animated: false)
        
        parentNavController.present(navigationController, animated: true)
    }
    
    func didFinishCreating(_ id: UUID?) {
        if let id = id {
            parentCoordinator?.watchlistCreated(id)
        }
        parentCoordinator?.childDidFinish(self)
        navigationController.dismiss(animated: true)
    }
    
}
