//
//  SearchVC.swift
//  CouchClub
//
//  Created by Ruben Dias on 26/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class SearchVC: UICollectionViewController {
    
    var searchResults = [SearchItem]()
    var searchType: ItemType = .movie
    
    var watchlist: Watchlist? {
        didSet {
            guard let watchlist = watchlist else { return }
            guard let type = ItemType(rawValue: watchlist.type) else { return }
            searchType = type
        }
    }
    
    private var itemsPerRow: Int = 3
    private var usableWidth: CGFloat = 0
    
    private var shouldCalculateSize = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) { isModalInPresentation = true }
        
        collectionView.register(SearchItemCell.self, forCellWithReuseIdentifier: SearchItemCell.reuseIdentifier)
        collectionView.register(SmallHeaderCVCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SmallHeaderCVCell.reuseIdentifier)
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search for a movie title"
        
        if watchlist == nil {
            searchController.searchBar.scopeButtonTitles = ["Movie", "Show"]
        }
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if shouldCalculateSize {
            shouldCalculateSize = false
            let size = CGSize(width: view.bounds.width, height: view.bounds.height)
            setupCollectionViewLayout(size)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let newSize = CGSize(width: size.width + 2 * 16, height: size.height)
        setupCollectionViewLayout(newSize)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    deinit {
        print("-- DEINIT -- Search VC")
    }
    
    private func setupCollectionViewLayout(_ size: CGSize) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            switch UIDevice.current.orientation {
            case .portrait, .portraitUpsideDown:
                itemsPerRow = 4
            default:
                itemsPerRow = 5
            }
        } else {
            itemsPerRow = 3
        }

        collectionView.contentInset = .init(top: 8, left: 16, bottom: 8, right: 16)
        usableWidth = size.width - 2 * 16
        updateItemSize()
    }
    
    private func updateItemSize() {
        let width: CGFloat = (usableWidth - CGFloat(itemsPerRow - 1) * 8) / CGFloat(itemsPerRow)
        let height: CGFloat = width * 3/2
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = .init(width: width, height: height)
        layout.headerReferenceSize = .init(width: usableWidth, height: 44)
    }
    
    func toggleActivityIndicator() {
        if navigationItem.rightBarButtonItem == nil {
            collectionView.isUserInteractionEnabled = false
            
            let activityIndicator = UIActivityIndicatorView(style: .gray)
            activityIndicator.startAnimating()
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        } else {
            navigationItem.rightBarButtonItem = nil
            collectionView.isUserInteractionEnabled = true
        }
    }

    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchItemDetail" {
            guard let item = sender as? Item else { return }
            guard let detailVC = segue.destination as? ItemDetailVC else { return }
            detailVC.item = item
            detailVC.watchlist = watchlist
        }
    }
    
}

extension SearchVC {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return searchResults.isEmpty ? 0 : 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SmallHeaderCVCell.reuseIdentifier, for: indexPath) as! SmallHeaderCVCell
        headerView.delegate = self
        headerView.text = "results"
        headerView.showButtons = true
        return headerView
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchItemCell.reuseIdentifier, for: indexPath) as! SearchItemCell
        let item = searchResults[indexPath.item]
        cell.searchItem = item
        
        if item.poster != "N/A" {
            DataCoordinator.shared.getImage(item.id, item.poster) { [weak cell] image in
                DispatchQueue.main.async {
                    if let image = image {
                        cell?.updateImage(image, for: item.id)
                    } else {
                        cell?.setImageUnavailable()
                    }
                }
            }
        } else {
            cell.setImageUnavailable()
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = searchResults[indexPath.item]
        
        switch searchType {
        case .movie:
            if let movie = LocalDatabase.shared.fetchItem(item.id) as? Movie {
                performSegue(withIdentifier: "SearchItemDetail", sender: movie)
            } else {
                toggleActivityIndicator()
                DataCoordinator.shared.getMovie(item.id) { [weak self] movie in
                    DispatchQueue.main.async {
                        if let movie = movie {
                            self?.performSegue(withIdentifier: "SearchItemDetail", sender: movie)
                        } else {
                            // TODO: display alert with error message
                        }
                        self?.toggleActivityIndicator()
                    }
                }
            }
        case .series:
            if let show = LocalDatabase.shared.fetchItem(item.id) as? Show {
                performSegue(withIdentifier: "SearchItemDetail", sender: show)
            } else {
                toggleActivityIndicator()
                DataCoordinator.shared.getShow(item.id) { [weak self] show in
                    DispatchQueue.main.async {
                        if let show = show {
                            self?.performSegue(withIdentifier: "SearchItemDetail", sender: show)
                        } else {
                            // TODO: display alert with error message
                        }
                        self?.toggleActivityIndicator()
                    }
                }
            }
        }
    }
    
}

extension SearchVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchType = selectedScope == 0 ? .movie : .series
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let userInput = searchBar.text else { return }
        navigationItem.searchController?.isActive = false
        navigationItem.searchController?.searchBar.text = userInput
        
        NetworkService.shared.searchResults(forType: searchType, searchText: userInput) { [weak self] results, totalResults in
            if let results = results as? [SearchItem] {
                self?.searchResults = results
                
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
        }
    }
    
}

extension SearchVC: HeaderButtonsDelegate {
    
    func didTapThumbnailsButton() {
        // TODO: change to thumbnails
    }
    
    func didTapListButton() {
        // TODO: change to list
    }
    
}
