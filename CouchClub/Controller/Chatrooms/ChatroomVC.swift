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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = chatroom.title
    }
    
    deinit {
        print("-- DEINIT -- Chatroom VC")
    }
    
    @IBAction func moreButtonTapped(_ sender: UIBarButtonItem) {
        // TODO: present chatroom options
    }
    
}
