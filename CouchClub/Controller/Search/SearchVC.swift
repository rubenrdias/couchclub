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
    var searchResults = [SearchItem]()
    
    private var itemsPerRow: Int = 3
    private var usableWidth: CGFloat = 0
    
    private var didLayoutSubviews = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(SearchItemCell.self, forCellWithReuseIdentifier: SearchItemCell.reuseIdentifier)
        collectionView.register(HeaderCVCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCVCell.reuseIdentifier)
        
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
            collectionView.contentInset = .init(top: 8, left: 16, bottom: 8, right: 16)
        } else {
            if UIDevice.current.orientation == .portrait {
                itemsPerRow = 3
                usableWidth = collectionView.bounds.width - 2 * 16
                collectionView.contentInset = .init(top: 8, left: 16, bottom: 8, right: 16)
            } else {
                itemsPerRow = 7
                usableWidth = collectionView.bounds.width - 16 - 44
                if UIDevice.current.orientation == .landscapeRight {
                    collectionView.contentInset = .init(top: 8, left: 16, bottom: 8, right: 44)
                } else {
                    collectionView.contentInset = .init(top: 8, left: 44, bottom: 8, right: 16)
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
        layout.headerReferenceSize = .init(width: usableWidth, height: 44)
    }

    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension SearchVC {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return searchResults.isEmpty ? 0 : 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCVCell.reuseIdentifier, for: indexPath) as! HeaderCVCell
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
        
        if item.poster != "N/A", let url = URL(string: item.poster) {
            NetworkService.shared.downloadImage(url) { [weak cell] image in
                DispatchQueue.main.async {
                    if let image = image {
                        cell?.updateImage(image, for: item.uuid)
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

extension SearchVC: HeaderButtonsDelegate {
    
    func didTapThumbnailsButton() {
        print("TODO: change to thumbnails mode")
    }
    
    func didTapListButton() {
        print("TODO: change to list mode")
    }
    
}
