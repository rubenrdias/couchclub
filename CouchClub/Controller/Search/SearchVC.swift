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
    
//    var searchResults = [SearchItem]()
    var searchResults = [
        SearchItem(uuid: "AAAA", title: "Hello", poster: "sdas"),
        SearchItem(uuid: "AAAA", title: "Hello", poster: "sdas"),
        SearchItem(uuid: "AAAA", title: "Hello", poster: "sdas"),
        SearchItem(uuid: "AAAA", title: "Hello", poster: "sdas"),
        SearchItem(uuid: "AAAA", title: "Hello", poster: "sdas"),
        SearchItem(uuid: "AAAA", title: "Hello", poster: "sdas"),
        SearchItem(uuid: "AAAA", title: "Hello", poster: "sdas"),
        SearchItem(uuid: "AAAA", title: "Hello", poster: "sdas"),
        SearchItem(uuid: "AAAA", title: "Hello", poster: "sdas"),
        SearchItem(uuid: "AAAA", title: "Hello", poster: "sdas")
    ]
    
    private var itemsPerRow: Int = 3
    private var usableWidth: CGFloat = 0
    
    private var didLayoutSubviews = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(SearchItemCell.self, forCellWithReuseIdentifier: SearchItemCell.reuseIdentifier)
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.scopeButtonTitles = ["Movies", "Shows"]
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search for a \(searchType) title"
        navigationItem.searchController = searchController
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !didLayoutSubviews {
            setupCollectionViewLayout()
            didLayoutSubviews = true
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.setupCollectionViewLayout()
        }, completion: nil)
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    private func setupCollectionViewLayout() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            switch UIDevice.current.orientation {
            case .portrait, .portraitUpsideDown:
                itemsPerRow = 4
            default:
                itemsPerRow = 5
            }
            if usableWidth == 0 {
                usableWidth = view.bounds.width - 2 * 16
            } else {
                usableWidth = collectionView.bounds.width - 2 * 16
            }
            collectionView.contentInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        } else {
            if UIDevice.current.orientation == .portrait {
                itemsPerRow = 3
                usableWidth = collectionView.bounds.width - 2 * 16
                collectionView.contentInset = .init(top: 16, left: 16, bottom: 16, right: 16)
            } else {
                itemsPerRow = 7
                usableWidth = collectionView.bounds.width - 16 - 44
                if UIDevice.current.orientation == .landscapeRight {
                    collectionView.contentInset = .init(top: 16, left: 16, bottom: 16, right: 44)
                } else {
                    collectionView.contentInset = .init(top: 16, left: 44, bottom: 16, right: 16)
                }
            }
        }
        
        updateItemSize()
    }
    
    private func updateItemSize() {
        let width: CGFloat = (usableWidth - CGFloat(itemsPerRow - 1) * 8) / CGFloat(itemsPerRow)
        let height: CGFloat = width * 3/2
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = .init(width: width, height: height)
    }

    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension SearchVC {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchItemCell.reuseIdentifier, for: indexPath) as! SearchItemCell
        cell.searchItem = searchResults[indexPath.item]
        return cell
    }
    
}

extension SearchVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchType = selectedScope == 0 ? "movie" : "series"
        navigationItem.searchController?.searchBar.placeholder = "Search for a \(searchType) title"
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let userInput = searchBar.text else { return }
        NetworkService.shared.searchResults(resultType: .movie, searchText: userInput) { [weak self] results, totalResults in
            if let results = results as? [SearchItem] {
                self?.searchResults = results
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
        }
    }
    
}
