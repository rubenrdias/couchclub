//
//  Protocols.swift
//  CouchClub
//
//  Created by Ruben Dias on 07/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import Foundation

protocol HeaderButtonsDelegate: AnyObject {
    func didTapThumbnailsButton()
    func didTapListButton()
}

protocol ItemOperationDelegate: AnyObject {
    func didTapSeen(_ item: Item)
}

protocol ItemSelectionDelegate: SelectionDelegate {
    func didSelectItem(_ id: String)
}

protocol WatchlistOperationDelegate: AnyObject {
    func didCreateWatchlist(_ id: UUID)
}

protocol WatchlistSelectionDelegate: SelectionDelegate {
    func didSelectWatchlist(_ id: UUID)
}

protocol ChatroomOperationDelegate: AnyObject {
    func didCreateChatroom(_ id: UUID)
}

protocol SelectionDelegate: AnyObject {
    func didCancelSelection()
}

protocol MessageDelegate: AnyObject {
    func didSendMessage(_ text: String)
}
