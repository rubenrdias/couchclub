//
//  SearchVC.swift
//  CouchClub
//
//  Created by Ruben Dias on 26/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class SearchVC: UICollectionViewController {
    
//    var searchResults = [SearchItem]()
    var searchResults = [
        SearchItem(uuid: "tt0848228", title: "The Avengers", poster: "https://m.media-amazon.com/images/M/MV5BNDYxNjQyMjAtNTdiOS00NGYwLWFmNTAtNThmYjU5ZGI2YTI1XkEyXkFqcGdeQXVyMTMxODk2OTU@._V1_SX300.jpg")
    ]
    
    private var itemsPerRow: Int = 3
    private var usableWidth: CGFloat = 0
    
    private var didLayoutSubviews = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(SearchItemCell.self, forCellWithReuseIdentifier: SearchItemCell.reuseIdentifier)
        collectionView.register(HeaderCVCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCVCell.reuseIdentifier)
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search for a movie title"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
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
            itemsPerRow = 3
            usableWidth = collectionView.bounds.width - 2 * 16
            collectionView.contentInset = .init(top: 8, left: 16, bottom: 8, right: 16)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchItemDetail" {
            guard let movie = sender as? Movie else { return }
            guard let detailVC = segue.destination as? SearchItemDetailVC else { return }
            
            detailVC.movie = movie
        }
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
        
        cell.updateImage(UIImage(named: "avengers_1")!, for: item.uuid)
        
//        if item.poster != "N/A", let url = URL(string: item.poster) {
//            NetworkService.shared.downloadImage(url) { [weak cell] image in
//                DispatchQueue.main.async {
//                    if let image = image {
//                        cell?.updateImage(image, for: item.uuid)
//                    } else {
//                        cell?.setImageUnavailable()
//                    }
//                }
//            }
//        } else {
//            cell.setImageUnavailable()
//        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = Movie(uuid: "tt0848228", title: "The Avengers", released: "04 May 2012", runtime: "143 min", genre: "Action, Adventure, Sci-Fi", imdbRating: "8.0", plot: "Nick Fury is the director of S.H.I.E.L.D., an international peace-keeping agency. The agency is a who's who of Marvel Super Heroes, with Iron Man, The Incredible Hulk, Thor, Captain America, Hawkeye and Black Widow. When global security is threatened by Loki and his cohorts, Nick Fury and his team will need all their powers to save the world from disaster.", actors: "Robert Downey Jr., Chris Evans, Mark Ruffalo, Chris Hemsworth", director: "Joss Whedon", writer: "Joss Whedon (screenplay), Zak Penn (story), Joss Whedon (story)", producer: "Walt Disney Pictures", awards: "Nominated for 1 Oscar. Another 38 wins & 79 nominations.", poster: "https://m.media-amazon.com/images/M/MV5BNDYxNjQyMjAtNTdiOS00NGYwLWFmNTAtNThmYjU5ZGI2YTI1XkEyXkFqcGdeQXVyMTMxODk2OTU@._V1_SX300.jpg", boxOffice: "$623,279,547")
        
        performSegue(withIdentifier: "SearchItemDetail", sender: movie)
//        let item = searchResults[indexPath.item]
//
//        collectionView.isUserInteractionEnabled = false
//        let activityIndicator = UIActivityIndicatorView(style: .gray)
//        activityIndicator.startAnimating()
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
//
//        NetworkService.shared.searchResult(forID: item.uuid, ofType: .movie) { [weak self] movie in
//            DispatchQueue.main.async {
//                if let movie = movie {
//                    self?.performSegue(withIdentifier: "SearchItemDetail", sender: movie)
//                }
//
//                self?.navigationItem.rightBarButtonItem = nil
//                self?.collectionView.isUserInteractionEnabled = true
//            }
//        }
    }
}

extension SearchVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let userInput = searchBar.text else { return }
        navigationItem.searchController?.isActive = false
        
        NetworkService.shared.searchResults(forType: .movie, searchText: userInput) { [weak self] results, totalResults in
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
