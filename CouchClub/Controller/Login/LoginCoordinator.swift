//
//  LoginCoordinator.swift
//  CouchClub
//
//  Created by Ruben Dias on 31/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import Foundation
import UIKit

class LoginCoordinator: NSObject, Coordinator {
    
    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(parentCoordinator: Coordinator) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = UINavigationController()
        super.init()
        
        let vc = LoginVC.instantiate()
        vc.coordinator = self
        if #available(iOS 13.0, *) { vc.isModalInPresentation = true }
        
        navigationController.viewControllers = [vc]
    }
    
    func start() {
        guard let parentNavController = parentCoordinator?.navigationController else {
            fatalError("LoginCoordinator should be started from within a parent coordinator.")
        }
        
        parentNavController.present(navigationController, animated: true)
    }
    
    func showCreateAccountScreen() {
        let vc = CreateAccountVC.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showLoginScreen() {
        navigationController.popViewController(animated: true)
    }
    
    func loggedIn() {
        userChanged()
        parentCoordinator?.childDidFinish(self)
        navigationController.dismiss(animated: true)
    }
    
    func accountCreated() {
        userChanged()
        parentCoordinator?.childDidFinish(self)
        navigationController.dismiss(animated: true)
    }
    
    private func userChanged() {
        if let parentCoordinator = parentCoordinator as? SettingsCoordinator {
            parentCoordinator.userDidChange()
        }
    }
    
}
