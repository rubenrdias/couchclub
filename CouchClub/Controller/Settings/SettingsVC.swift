//
//  SettingsVC.swift
//  CouchClub
//
//  Created by Ruben Dias on 25/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsVC: UITableViewController {
    
    var presentingLoginScreen = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = .init(top: 8, left: 0, bottom: 8, right: 0)
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if presentingLoginScreen {
            tableView.reloadData()
            presentingLoginScreen = false
        }
    }

}

extension SettingsVC {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let currentUser = LocalDatabase.shared.fetchCurrentuser()
            let cell = UITableViewCell()
            cell.textLabel?.text = "Logged in as \(currentUser.username)"
            cell.textLabel?.textAlignment = .left
            return cell
        } else {
            let cell = UITableViewCell()
            cell.textLabel?.text = "Log Out"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .systemRed
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        FirebaseService.shared.signOut { (error) in
            if let error = error {
                let alert = Alerts.simpleAlert(title: "Failed", message: error.localizedDescription)
                present(alert, animated: true)
            } else {
                presentingLoginScreen = true
                performSegue(withIdentifier: "LoginVC", sender: nil)
                
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    tableView.deselectRow(at: selectedIndexPath, animated: true)
                }
            }
        }
    }
    
}
