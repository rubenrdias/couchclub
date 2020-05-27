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

    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    private weak var watchlistOperationDelegate: WatchlistOperationDelegate?
    
    init() {
        self.navigationController = UINavigationController()
    }
    
    func start() {
        guard let parentNavController = parentCoordinator?.navigationController else {
            fatalError("NewWatchlistCoordinator should be started from within a parent coordinator.")
        }
        
        let vc = NewWatchlistVC.instantiate()
        vc.delegate = watchlistOperationDelegate
        
        navigationController.pushViewController(vc, animated: false)
        
        parentNavController.modalPresentationStyle = .overCurrentContext
        parentNavController.present(navigationController, animated: true)
    }
    
    func start(delegate: WatchlistOperationDelegate?) {
        watchlistOperationDelegate = delegate
        start()
    }
    
}
