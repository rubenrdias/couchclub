//
//  ChatroomsVC.swift
//  CouchClub
//
//  Created by Ruben Dias on 25/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class ChatroomsVC: UITableViewController {
    
    var chatrooms = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchData), name: .chatroomsDidChange, object: nil)
        
        fetchData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewChatroomVC" {
            guard let navController = segue.destination as? UINavigationController else { return }
            guard let newChatroomVC = navController.viewControllers.first as? NewChatroomVC else { return }
            newChatroomVC.delegate = self
        }
//        else if segue.identifier == "WatchlistVC" {
//            guard let watchlist = sender as? Watchlist else { return }
//            guard let watchlistVC = segue.destination as? WatchlistVC else { return }
//            watchlistVC.watchlist = watchlist
//        }
    }
    
    @objc private func fetchData() {
        DispatchQueue.main.async { [weak self] in
//            guard let watchlists = LocalDatabase.shared.fetchWatchlists() else { return }
//            self?.watchlists = watchlists
//
//            self?.tableView.reloadData()
            self?.evaluateDataAvailable()
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
        btn.titleLabel?.font = UIFont.translatedFont(for: .headline, .semibold)
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

extension ChatroomsVC: ChatroomOperationDelegate {
    
    func didCreateChatroom(_ id: UUID) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
//            guard let watchlist = LocalDatabase.shared.fetchWatchlist(id) else { return }
//            self?.performSegue(withIdentifier: "WatchlistVC", sender: watchlist)
//        }
    }
    
}
