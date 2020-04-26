//
//  SearchVC.swift
//  CouchClub
//
//  Created by Ruben Dias on 26/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class SearchVC: UICollectionViewController {
    
    var searchType: String = "movie"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.scopeButtonTitles = ["Movies", "Shows"]
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }

    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension SearchVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchType = selectedScope == 0 ? "movie" : "series"
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Begin search...")
    }
    
}
