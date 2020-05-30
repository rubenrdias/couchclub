//
//  SelectWatchlistVC.swift
//  CouchClub
//
//  Created by Ruben Dias on 12/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class SelectWatchlistVC: UITableViewController, Storyboarded {
    
    weak var coordinator: NewChatroomCoordinator?
    
    private let cellId = "cellId"
    private let watchlists = LocalDatabase.shared.fetchWatchlists()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem?.action = #selector(cancelSelection)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
    }
    
    @objc private func cancelSelection() {
        coordinator?.didCancelSelection()
    }
    
}

extension SelectWatchlistVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchlists?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let watchlist = watchlists?[indexPath.row] else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = watchlist.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let watchlist = watchlists?[indexPath.row] else { return }
        coordinator?.didSelectWatchlist(watchlist.id)
    }
    
}
