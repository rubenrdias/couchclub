//
//  ChatroomsVC.swift
//  CouchClub
//
//  Created by Ruben Dias on 25/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class ChatroomsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var chatrooms = [Chatroom]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchData), name: .chatroomsDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchChatroomMessages), name: .newMessage, object: nil)
        
        tableView.register(ChatroomTVCell.self, forCellReuseIdentifier: ChatroomTVCell.reuseIdentifier)
        
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewChatroomVC" {
            guard let navController = segue.destination as? UINavigationController else { return }
            guard let newChatroomVC = navController.viewControllers.first as? NewChatroomVC else { return }
            newChatroomVC.delegate = self
        }
        else if segue.identifier == "ChatroomVC" {
            guard let chatroom = sender as? Chatroom else { return }
            guard let chatroomVC = segue.destination as? ChatroomVC else { return }
            chatroomVC.chatroom = chatroom
        }
    }
    
    @objc private func fetchData() {
        DispatchQueue.main.async { [weak self] in
            guard let chatrooms = LocalDatabase.shared.fetchChatrooms() else { return }
            self?.chatrooms = chatrooms

            self?.tableView.reloadData()
            self?.evaluateDataAvailable()
        }
    }
    
    @objc private func fetchChatroomMessages(_ notification: Notification) {
        guard let info = notification.userInfo else { return }
        
        if let chatroomID = info["chatroomID"] as? UUID {
            if let index = chatrooms.firstIndex(where: { $0.id == chatroomID }) {
                tableView.reloadRows(at: [.init(row: index, section: 0)], with: .automatic)
            }
        }
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
    
    private lazy var createChatroomButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Create Chatroom", for: .normal)
        btn.titleLabel?.font = .translatedFont(for: .headline, .semibold)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = UIColor.systemOrange
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(createChatroom), for: .touchUpInside)
        return btn
    }()
    
    @objc private func createChatroom() {
        performSegue(withIdentifier: "NewChatroomVC", sender: nil)
    }
    
    private lazy var createChatroomButtonConstraints: [NSLayoutConstraint] = {
        return [
            createChatroomButton.heightAnchor.constraint(equalToConstant: 56),
            createChatroomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            createChatroomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createChatroomButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32)
        ]
    }()
    
    private func evaluateDataAvailable() {
        if chatrooms.isEmpty {
            navigationItem.rightBarButtonItem = nil
            view.addSubview(noDataLabel)
            view.addSubview(createChatroomButton)
            NSLayoutConstraint.activate(noDataLabelConstraints)
            NSLayoutConstraint.activate(createChatroomButtonConstraints)
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createChatroom))
            noDataLabel.removeFromSuperview()
            createChatroomButton.removeFromSuperview()
        }
    }

}

extension ChatroomsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatroomTVCell.reuseIdentifier, for: indexPath) as! ChatroomTVCell
        cell.chatroom = chatrooms[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ChatroomVC", sender: chatrooms[indexPath.row])
    }
    
}

extension ChatroomsVC: ChatroomOperationDelegate {
    
    func didCreateChatroom(_ id: UUID) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let watchlist = LocalDatabase.shared.fetchChatroom(id) else { return }
            self?.performSegue(withIdentifier: "ChatroomVC", sender: watchlist)
        }
    }
    
}
