//
//  ChatroomsDataSource.swift
//  CouchClub
//
//  Created by Ruben Dias on 04/06/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class ChatroomsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    var chatrooms = [Chatroom]()
    weak var delegate: ChatroomsDataSourceDelegate?
    
    convenience init(delegate: ChatroomsDataSourceDelegate? = nil) {
        self.init()
        self.delegate = delegate
    }
    
    override init() {
        super.init()
        
        fetchData()
    }
    
    @objc func fetchData() {
        DispatchQueue.main.async { [weak self] in
            let chatrooms = LocalDatabase.shared.fetchChatrooms()
            if chatrooms != nil {
                self?.chatrooms = chatrooms!
            } else {
                self?.chatrooms.removeAll()
            }

            self?.delegate?.didRefreshData()
        }
    }
    
    func indexOf(_ id: UUID) -> Int? {
        return chatrooms.firstIndex(where: { $0.id == id })
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
        delegate?.didTapChatroom(chatroom)
    }
    
}
