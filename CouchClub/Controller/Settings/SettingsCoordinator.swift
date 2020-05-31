//
//  SettingsCoordinator.swift
//  CouchClub
//
//  Created by Ruben Dias on 30/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import Foundation
import UIKit

class SettingsCoordinator: NSObject, Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    override init() {
        let navController = UINavigationController()
        navController.navigationBar.prefersLargeTitles = true
        
        self.navigationController = navController
        super.init()
        
        let vc = SettingsVC.instantiate()
        vc.tabBarItem = UITabBarItem(title: "Settings", image: .iconAsset(.settings), tag: 2)
        vc.coordinator = self
        self.navigationController.viewControllers = [vc]
    }
    
    func showLogin() {
        let child = LoginCoordinator(parentCoordinator: self)
        childCoordinators.append(child)
        child.start()
    }
    
    func userDidChange() {
        guard let vc = navigationController.viewControllers[0] as? SettingsVC else { return }
        vc.userDidChange()
    }
}
