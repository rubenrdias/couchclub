//
//  File.swift
//  CouchClub
//
//  Created by Ruben Dias on 27/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class SearchItemDetailVC: UITableViewController {
    
    var movie: Movie!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) { isModalInPresentation = true }
        
        tableView.register(ItemDetailHeaderTVCell.self, forHeaderFooterViewReuseIdentifier: ItemDetailHeaderTVCell.reuseIdentifier)
        
        setupToolbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    @IBAction func startChatroomTapped(_ sender: UIBarButtonItem) {
        // TODO: start chatroom...
    }
    
    @objc private func addToWatchlist() {
        // TODO: add to watchlist
    }
    
    private func setupToolbar() {
        let spaceButton1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let spaceButton2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let addButton = UIBarButtonItem(title: "Add to Watchlist", style: .plain, target: self, action: #selector(addToWatchlist))
        
        toolbarItems = [spaceButton1, addButton, spaceButton2]
    }
    
}

extension SearchItemDetailVC {
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ItemDetailHeaderTVCell.reuseIdentifier) as! ItemDetailHeaderTVCell
        headerView.updateText(movie)
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 150 + 2 * 16
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "AAA"
        return cell
    }
    
}
