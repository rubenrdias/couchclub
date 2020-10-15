//
//  ChatroomsDataSource.swift
//  CouchClub
//
//  Created by Ruben Dias on 04/06/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class ChatroomsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    private var chatrooms = [Chatroom]()
    weak var delegate: ChatroomsDataSourceDelegate?
    
    var isEmpty: Bool {
        return chatrooms.isEmpty
    }
    
    init(delegate: ChatroomsDataSourceDelegate? = nil) {
        super.init()
        self.delegate = delegate
        
        fetchData()
    }
    
    @objc func fetchData() {
        DispatchQueue.main.async { [weak self] in
            self?.chatrooms = LocalDatabase.shared.fetchChatrooms()
            self?.delegate?.didRefreshData()
        }
    }
    
    func indexOf(_ id: UUID) -> Int? {
        return chatrooms.firstIndex(where: { $0.id == id })
    }
	
	func updateUserInfo(_ user: User) {
		var indices = [IndexPath]()
		
		for (index, chatroom) in chatrooms.enumerated() {
			if chatroom.users.contains(user) {
				indices.append(.init(row: index, section: 0))
			}
		}
		
		if !indices.isEmpty {
			delegate?.shouldReloadRows(indices)
		}
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
