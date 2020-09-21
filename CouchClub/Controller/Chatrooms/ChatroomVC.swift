//
//  ChatroomVC.swift
//  CouchClub
//
//  Created by Ruben Dias on 07/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit
import CoreData

class ChatroomVC: UITableViewController, Storyboarded {
    
    weak var coordinator: ChatroomsCoordinator?
    lazy var dataSource = ChatroomMessagesDataSource(chatroom: chatroom, tableView: tableView, delegate: self)
    
    var chatroom: Chatroom! {
        didSet {
            title = chatroom.title
        }
    }
    
    private var leavingChatroom: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(chatroomsWereUpdated), name: .chatroomsDidChange, object: nil)
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: .iconAsset(.more), style: .plain, target: self, action: #selector(moreButtonTapped)),
            UIBarButtonItem(image: .iconAsset(.invite), style: .plain, target: self, action: #selector(inviteButtonTapped))
        ]
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editingFinished))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        configureTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollToBottom()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("-- DEINIT -- Chatroom VC")
    }
    
    @objc private func chatroomsWereUpdated() {
        DispatchQueue.main.async { [weak self] in
            guard let leavingChatroom = self?.leavingChatroom, !leavingChatroom else { return }
            
            let chatrooms = LocalDatabase.shared.fetchChatrooms()
            if chatrooms?.firstIndex(where: { $0.id == self?.chatroom.id }) == nil, self?.chatroom.owner.id != FirebaseService.currentUserID {
                let alert = Alerts.simpleAlert(title: "Chatroom was deleted", message: "The chatroom owner has deleted this chatroom. It will now be deleted from the device.") { _ in
                    self?.resignFirstResponder()
                    self?.coordinator?.chatroomDismissed()
                }
                self?.present(alert, animated: true)
            }
        }
    }
    
    @objc private func editingFinished() {
        messageAccessoryView.dismissKeyboard()
    }
    
    lazy var messageAccessoryView: MessageInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let messageInputAccessoryView = MessageInputAccessoryView(frame: frame)        
        messageInputAccessoryView.delegate = self
        return messageInputAccessoryView
    }()
    
    override var inputAccessoryView: UIView? {
        get { return messageAccessoryView }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @objc private func moreButtonTapped(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.view.tintColor = .colorAsset(.dynamicLabel)
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if chatroom.owner === LocalDatabase.shared.fetchCurrentuser() {
            ac.addAction(UIAlertAction(title: "Delete Chatroom", style: .destructive) { [unowned self] _ in
                let deletionAlert = Alerts.deletionAlert(title: "Are you sure?", message: "This action is irreversible.") { _ in
                    DataCoordinator.shared.deleteChatroom(self.chatroom) { error in
                        if let error = error {
                            let alert = Alerts.simpleAlert(title: "Failed", message: error.localizedDescription)
                            self.present(alert, animated: true)
                        } else {
                            self.coordinator?.chatroomDismissed()
                        }
                    }
                }
                
                self.present(deletionAlert, animated: true, completion: nil)
            })
        }
        
        ac.addAction(UIAlertAction(title: "Leave Chatroom", style: .destructive) { [unowned self] _ in
            self.leavingChatroom = true
            
            let deletionAlert = Alerts.deletionAlert(title: "Are you sure?", message: "You can only rejoin later by with an invite code.") { _ in
                DataCoordinator.shared.leaveChatroom(self.chatroom) { error in
                    if let error = error {
                        let alert = Alerts.simpleAlert(title: "Failed", message: error.localizedDescription)
                        self.present(alert, animated: true)
                        self.leavingChatroom = false
                    } else {
                        self.coordinator?.chatroomDismissed()
                    }
                }
            }
            
            self.present(deletionAlert, animated: true, completion: nil)
        })
                
        ac.popoverPresentationController?.barButtonItem = sender
        present(ac, animated: true, completion: nil)
    }
    
    @objc private func inviteButtonTapped(_ sender: Any) {
        messageAccessoryView.dismissKeyboard()
        resignFirstResponder()
        Alerts.shared.presentInviteCodeShareDialog(chatroom.inviteCode, action: copyInviteCodeToClipboard, dismissAction: dismissInviteCodeDialog)
    }
    
    func copyInviteCodeToClipboard() {
        UIPasteboard.general.string = chatroom.inviteCode
        Alerts.shared.dismissActivityAlert(message: "Copied to clipboard!") { [weak self] in
            self?.becomeFirstResponder()
        }
    }
    
    func dismissInviteCodeDialog() {
        becomeFirstResponder()
    }
    
    private func configureTableView() {
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        
        tableView.backgroundColor = .colorAsset(.dynamicBackground)
        tableView.contentInset = .init(top: 8, left: 0, bottom: 8, right: 0)
        
        tableView.register(SmallHeaderTVCell.self, forHeaderFooterViewReuseIdentifier: SmallHeaderTVCell.reuseIdentifier)
        tableView.register(MessageTVCell.self, forCellReuseIdentifier: MessageTVCell.reuseIdentifier)
    }
    
    func scrollToBottom() {
        guard let bottomIndexPath = dataSource.bottomIndexPath() else { return }
        tableView.scrollToRow(at: bottomIndexPath, at: .bottom, animated: true)
    }
    
}

extension ChatroomVC: MessageDelegate {
    
    func shouldSendMessage(_ text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        DataCoordinator.shared.createMessage(trimmedText, in: chatroom) { [unowned self] (error) in
            if let error = error {
                let alert = Alerts.simpleAlert(title: "Failed", message: error.localizedDescription)
                self.present(alert, animated: true)
            }
        }
    }
    
}

extension ChatroomVC: MessagesDataSourceDelegate {
    
    func dataWasUpdated() {
        scrollToBottom()
    }
}
