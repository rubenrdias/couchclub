//
//  ChatroomsVC.swift
//  CouchClub
//
//  Created by Ruben Dias on 25/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class ChatroomsVC: UIViewController, Storyboarded {
    
    weak var coordinator: ChatroomsCoordinator?
    
    @IBOutlet weak var tableView: UITableView!
    
    var chatrooms = [Chatroom]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Chatrooms"
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchData), name: .chatroomsDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshChatroom), name: .chatroomDidChange, object: nil)
        
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }
    
    @objc private func fetchData() {
        DispatchQueue.main.async { [weak self] in
            let chatrooms = LocalDatabase.shared.fetchChatrooms()
            if chatrooms != nil {
                self?.chatrooms = chatrooms!
            } else {
                self?.chatrooms.removeAll()
            }

            self?.tableView.reloadData()
            self?.evaluateDataAvailable()
        }
    }
    
    @objc private func refreshChatroom(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            guard let info = notification.userInfo else { return }
            guard let chatroomID = info["chatroomID"] as? UUID else { return }
            
            if let index = self?.chatrooms.firstIndex(where: { $0.id == chatroomID }) {
                self?.tableView.reloadRows(at: [.init(row: index, section: 0)], with: .automatic)
            }
        }
    }
    
    @objc private func newChatroomDialog() {
        let ac = UIAlertController(title: nil, message: "Would you like to create a new Chatroom or join an existing one?", preferredStyle: .actionSheet)
        ac.popoverPresentationController?.sourceView = self.view
        
        if chatrooms.isEmpty {
            ac.popoverPresentationController?.sourceRect = newChatroomButton.frame
        } else {
            ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        ac.view.tintColor = .colorAsset(.dynamicLabel)
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        ac.addAction(UIAlertAction(title: "Create Chatroom", style: .default, handler: { [unowned self] (_) in
            self.coordinator?.newChatroom()
        }))
        
        ac.addAction(UIAlertAction(title: "Join Chatroom", style: .default, handler: { [unowned self] (_) in
            self.presentJoinChatroomDialog()
        }))
        
        present(ac, animated: true)
    }
    
    private func presentJoinChatroomDialog() {
        let alert = UIAlertController(title: "Invite Code", message: nil, preferredStyle: .alert)
        alert.view.tintColor = UIColor.systemOrange
        
        alert.addTextField { (textfield) in
            textfield.tintColor = .colorAsset(.dynamicLabel)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Join", style: .default, handler: { [unowned self, weak alert] (_) in
            guard let inviteCode = alert?.textFields?[0].text else { return }
            
            let chatrooms = LocalDatabase.shared.fetchChatrooms()
            if chatrooms?.first(where: { $0.inviteCode == inviteCode }) == nil {
                Alerts.shared.presentActivityAlert(title: "Attempting to join chatroom...", subtitle: nil, showSpinner: true, action: nil) {
                    DataCoordinator.shared.joinChatroom(inviteCode) { (_, error) in
                        let message = error == nil ? "Success!" : "Failed. Please try again later."
                        Alerts.shared.dismissActivityAlert(message: message)
                    }
                }
            } else {
                let alert = Alerts.simpleAlert(title: "Invalid Code", message: "This chatroom is already on this device.")
                self.present(alert, animated: true)
            }
        }))
        
        self.present(alert, animated: true)
    }
    
    private lazy var noDataLabel: UILabel = {
        let lbl = UILabel()
        lbl.attributedText = noDataText
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private lazy var noDataLabelConstraints: [NSLayoutConstraint] = {
        return [
            noDataLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            noDataLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            noDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
    }()
    
    private lazy var noDataText: NSMutableAttributedString = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 8
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 1.15
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.colorAsset(.dynamicLabel),
            .font: UIFont.translatedFont(for: .title2, .semibold),
            .paragraphStyle: paragraphStyle
        ]
        let attributtedString = NSMutableAttributedString(string: "No chatrooms found...\n", attributes: titleAttributes)
        
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.colorAsset(.dynamicLabelSecondary),
            .font: UIFont.translatedFont(for: .subheadline, .regular),
            .paragraphStyle: paragraphStyle
        ]
        attributtedString.append(NSAttributedString(string: "You can use Chatrooms to discuss watchlists, movies or shows with your friends.", attributes: subtitleAttributes))
        
        return attributtedString
    }()
    
    private lazy var newChatroomButton: RoundedButton = {
        let btn = RoundedButton()
        btn.makeCTA()
        btn.setTitle("New Chatroom", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(newChatroomDialog), for: .touchUpInside)
        return btn
    }()
    
    private lazy var createChatroomButtonConstraints: [NSLayoutConstraint] = {
        return [
            newChatroomButton.heightAnchor.constraint(equalToConstant: 56),
            newChatroomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            newChatroomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            newChatroomButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32)
        ]
    }()
    
    private func evaluateDataAvailable() {
        if chatrooms.isEmpty {
            tableView.alwaysBounceVertical = false
            navigationItem.rightBarButtonItem = nil
            view.addSubview(noDataLabel)
            view.addSubview(newChatroomButton)
            NSLayoutConstraint.activate(noDataLabelConstraints)
            NSLayoutConstraint.activate(createChatroomButtonConstraints)
        } else {
            tableView.alwaysBounceVertical = true
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newChatroomDialog))
            noDataLabel.removeFromSuperview()
            newChatroomButton.removeFromSuperview()
        }
    }
    
    func didCreateChatroom(_ id: UUID) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [unowned self] in
            guard let chatroom = LocalDatabase.shared.fetchChatroom(id) else { return }
            self.coordinator?.showDetail(chatroom)
        }
    }
    
}

extension ChatroomsVC: UITableViewDataSource, UITableViewDelegate {
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(ChatroomTVCell.self, forCellReuseIdentifier: ChatroomTVCell.reuseIdentifier)
        
        fetchData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatroomTVCell.reuseIdentifier, for: indexPath) as! ChatroomTVCell
        cell.chatroom = chatrooms[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatroom = chatrooms[indexPath.row]
        coordinator?.showDetail(chatroom)
    }
    
}
