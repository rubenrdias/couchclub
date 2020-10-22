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
    
    var chatroom: Chatroom!
    private var leavingChatroom: Bool = false
    private var accessoryViewHeight: CGFloat = 50
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("-- DEINIT -- Chatroom VC")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupObservers()
        setupUI()
        setupGestures()
        configureTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollToBottom()
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(chatroomsWereUpdated), name: .chatroomsChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(beganWritingMessage), name: .beganWritingMessage, object: nil)
    }
    
    private func setupUI() {
        title = chatroom.title
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: .iconAsset(.more), style: .plain, target: self, action: #selector(moreButtonTapped)),
            UIBarButtonItem(image: .iconAsset(.invite), style: .plain, target: self, action: #selector(inviteButtonTapped))
        ]
        
        tableView.tableFooterView = UIView()
    }
    
    private func setupGestures() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editingFinished))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func chatroomsWereUpdated() {
        DispatchQueue.main.async { [weak self] in
            guard let leavingChatroom = self?.leavingChatroom, !leavingChatroom else { return }
            
            let chatrooms = LocalDatabase.shared.fetchChatrooms()
            if chatrooms.firstIndex(where: { $0.id == self?.chatroom.id }) == nil, self?.chatroom.owner.id != FirebaseService.shared.currentUserID {
                let alert = Alerts.simpleAlert(title: "Chatroom was deleted", message: "The chatroom owner has deleted this chatroom. It will now be deleted from the device.") { _ in
                    self?.resignFirstResponder()
                    self?.coordinator?.chatroomDismissed()
                }
                self?.present(alert, animated: true)
            }
        }
    }
    
    @objc private func beganWritingMessage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.scrollToBottom()
        }
    }
    
    @objc private func editingFinished() {
        messageAccessoryView.dismissKeyboard()
    }
    
    lazy var messageAccessoryView: MessageInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: accessoryViewHeight)
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
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
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
            } else {
                self.scrollToBottom()
            }
        }
    }
    
}

extension ChatroomVC: MessagesDataSourceDelegate {
    
    func dataWasUpdated() {
        // TODO: show new messages alert
    }
}
