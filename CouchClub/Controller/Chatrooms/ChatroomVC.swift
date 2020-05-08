//
//  ChatroomVC.swift
//  CouchClub
//
//  Created by Ruben Dias on 07/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class ChatroomVC: UITableViewController {
    
    var chatroom: Chatroom!
    var messages: [String] = [
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
        "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
        "Smaller message",
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
        "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
        "Smaller message",
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
        "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
        "Smaller message",
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
        "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
        "Smaller message"
    ]
    lazy var senders = [
        true, false, false,
        false, true, true,
        false, true, false,
        true, true, false
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editingFinished))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        tableView.register(MessageTVCell.self, forCellReuseIdentifier: MessageTVCell.reuseIdentifier)
        
        title = chatroom.title
    }
    
    deinit {
        print("-- DEINIT -- Chatroom VC")
    }
    
    @objc private func editingFinished() {
        inputAccessoryViewContainer.dismissKeyboard()
    }
    
    lazy var inputAccessoryViewContainer: MessageInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let commentInputAccessoryView = MessageInputAccessoryView(frame: frame)
//        commentInputAccessoryView.delegate = self
        return commentInputAccessoryView
    }()
    
    override var inputAccessoryView: UIView? {
        get { return inputAccessoryViewContainer }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @IBAction func moreButtonTapped(_ sender: UIBarButtonItem) {
        // TODO: present chatroom options
    }
    
}

extension ChatroomVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageTVCell.reuseIdentifier, for: indexPath) as! MessageTVCell
        cell.message = messages[indexPath.row]
        cell.sender = senders[indexPath.row]
        return cell
    }
    
}
