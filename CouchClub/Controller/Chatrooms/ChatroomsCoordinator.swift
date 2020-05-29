//
//  ChatroomsCoordinator.swift
//  CouchClub
//
//  Created by Ruben Dias on 28/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class ChatroomsCoordinator: NSObject, Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    override init() {
        let navController = UINavigationController()
        navController.modalPresentationStyle = .overCurrentContext
        navController.navigationBar.prefersLargeTitles = true
        
        self.navigationController = navController
        super.init()
        
        let vc = ChatroomsVC.instantiate()
        vc.tabBarItem = UITabBarItem(title: "Chatrooms", image: .iconAsset(.chatrooms), tag: 1)
        vc.coordinator = self
        self.navigationController.viewControllers = [vc]
    }
    
    func showDetail(_ chatroom: Chatroom) {
        let vc = ChatroomVC.instantiate()
        vc.chatroom = chatroom
        navigationController.pushViewController(vc, animated: true)
    }
    
    func newChatroom() {
        let child = NewChatroomCoordinator(parentCoordinator: self)
        childCoordinators.append(child)
        child.start()
    }
    
    func chatroomCreated(_ id: UUID) {
        guard let vc = navigationController.viewControllers[0] as? ChatroomsVC else { return }
        vc.didCreateChatroom(id)
    }
    
}
