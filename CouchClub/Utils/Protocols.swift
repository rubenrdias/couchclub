//
//  Protocols.swift
//  CouchClub
//
//  Created by Ruben Dias on 07/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func childDidFinish(_ child: Coordinator?)
}

extension Coordinator {
    func childDidFinish(_ child: Coordinator?) {
        if let index = childCoordinators.firstIndex(where: { $0 === child }) {
            childCoordinators.remove(at: index)
        }
    }
}

protocol Storyboarded {
    static func instantiate() -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate() -> Self {
        let id = String(describing: self)
        let storyboardName = UIStoryboard.name(for: id)
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: id) as! Self
    }
}

protocol HeaderButtonsDelegate: AnyObject {
    func didTapThumbnailsButton()
    func didTapListButton()
}

protocol SelectionDelegate: WatchlistSelectionDelegate & ItemSelectionDelegate {
    func didCancelSelection()
}

protocol WatchlistSelectionDelegate: AnyObject {
    func didSelectWatchlist(_ id: UUID)
}

protocol HandlesItemDetail {
    func showItemDetail(_ item: Item, watchlist: Watchlist?)
}

protocol ItemSelectionDelegate: AnyObject {
    func didSelectItem(_ id: String)
}

protocol ItemActionDelegate: AnyObject {
    func didTapActionButton(_ item: Item)
}

protocol ItemOperationDelegate: AnyObject {
    func didTapSeen(_ item: Item)
}

protocol MessageDelegate: AnyObject {
    func shouldSendMessage(_ text: String)
}

// MARK: - Data Sources

protocol ChatroomsDataSourceDelegate: AnyObject {
    func didRefreshData()
    func didTapChatroom(_ chatroom: Chatroom)
}


