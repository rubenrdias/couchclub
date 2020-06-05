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
    lazy var dataSource = WatchlistSelectionDataSource(tableView: tableView, delegate: self)
    
    private var didSelectWatchlist = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !didSelectWatchlist {
            coordinator?.didCancelSelection()
        }
    }
    
    deinit {
        print("-- DEINIT -- Select Watchlist VC")
    }
    
    private func configureTableView() {
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
    }
    
}

extension SelectWatchlistVC: WatchlistSelectionDelegate {
    
    func didSelectWatchlist(_ id: UUID) {
        didSelectWatchlist = true
        coordinator?.didSelectWatchlist(id)
    }
    
}
