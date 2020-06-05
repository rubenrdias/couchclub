//
//  WatchlistSelectionDataSource.swift
//  CouchClub
//
//  Created by Ruben Dias on 05/06/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class WatchlistSelectionDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    private var watchlists = [Watchlist]()
    weak var tableView: UITableView!
    weak var delegate: WatchlistSelectionDelegate?
    
    var cellID = "cell"
    
    convenience init(tableView: UITableView, delegate: WatchlistSelectionDelegate? = nil) {
        self.init()
        self.tableView = tableView
        self.delegate = delegate
        
        if let watchlists = LocalDatabase.shared.fetchWatchlists() {
            self.watchlists = watchlists
        }
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        self.tableView.tableFooterView = UIView()
    }
    
    deinit {
        print("-- DEINIT -- Watchlist Selection Data Source")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.textLabel?.text = watchlists[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let watchlist = watchlists[indexPath.row]
        delegate?.didSelectWatchlist(watchlist.id)
    }
}
