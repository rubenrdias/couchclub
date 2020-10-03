//
//  MainTabBarController.swift
//  CouchClub
//
//  Created by Ruben Dias on 27/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, Storyboarded {
    
    let watchlists = WatchlistsCoordinator()
    let chatrooms = ChatroomsCoordinator()
    let settings = SettingsCoordinator()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = [watchlists.navigationController, chatrooms.navigationController, settings.navigationController]
    }
	
	func resetScreens() {
		viewControllers?.forEach {
			guard let navController = $0 as? UINavigationController else { return }
			navController.popToRootViewController(animated: false)
		}
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [unowned self] in
            self.selectedIndex = 0
        }
	}

}
