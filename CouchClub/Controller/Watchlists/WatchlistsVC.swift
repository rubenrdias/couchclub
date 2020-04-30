//
//  ViewController.swift
//  CouchClub
//
//  Created by Ruben Dias on 25/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit
import CoreData

class WatchlistsVC: UICollectionViewController {
    
    private var itemsPerRow: Int = 1
    private var usableWidth: CGFloat = 0
    
    var watchlists = [Watchlist]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchData), name: .watchlistsChanged, object: nil)
        
        collectionView.register(WatchlistCell.self, forCellWithReuseIdentifier: WatchlistCell.reuseIdentifier)
        
        setupCollectionViewLayout()
        fetchData()
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
                itemsPerRow = 2
            default:
                itemsPerRow = 3
            }
            usableWidth = collectionView.bounds.width - 2 * 16
            collectionView.contentInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        } else {
            itemsPerRow = 1
            usableWidth = collectionView.bounds.width - 2 * 16
            collectionView.contentInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        }
        
        updateItemSize()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewWatchlistVC" {
            guard let navController = segue.destination as? UINavigationController else { return }
            guard let newWatchlistVC = navController.viewControllers.first as? NewWatchlistVC else { return }
            newWatchlistVC.delegate = self
        }
        else if segue.identifier == "WatchlistVC" {
            guard let watchlist = sender as? Watchlist else { return }
            guard let watchlistVC = segue.destination as? WatchlistVC else { return }
            watchlistVC.watchlist = watchlist
        }
    }
    
    @objc private func fetchData() {
        DispatchQueue.main.async { [weak self] in
            guard let watchlists = LocalDatabase.shared.fetchWatchlists() else { return }
            self?.watchlists = watchlists
            
            self?.collectionView.reloadData()
            self?.evaluateDataAvailable()
        }
    }
    
    private func updateItemSize() {
        let width: CGFloat = (usableWidth - CGFloat(itemsPerRow - 1) * 16) / CGFloat(itemsPerRow)
        let height: CGFloat = width * 230/343
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = .init(width: width, height: height)
    }
    
    private lazy var noDataLabel: UILabel = {
        let lbl = UILabel()
        lbl.attributedText = noDataText
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private lazy var noDataLabelConstraints: [NSLayoutConstraint] = {
        return [
            noDataLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            noDataLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            noDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0)
        ]
    }()
    
    private lazy var noDataText: NSMutableAttributedString = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 8
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 1.15
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.colorAsset(.dynamicLabel),
            .font: UIFont.translatedFont(for: .headline, .semibold),
            .paragraphStyle: paragraphStyle
        ]
        let attributtedString = NSMutableAttributedString(string: "No watchlists found...\n", attributes: titleAttributes)
        
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.colorAsset(.dynamicLabelSecondary),
            .font: UIFont.translatedFont(for: .footnote, .regular),
            .paragraphStyle: paragraphStyle
        ]
        attributtedString.append(NSAttributedString(string: "Watchlists can be used to track movies you want to watch or have seen. Create one to start tracking!", attributes: subtitleAttributes))
        
        return attributtedString
    }()
    
    private func evaluateDataAvailable() {
        if watchlists.isEmpty {
            view.addSubview(noDataLabel)
            NSLayoutConstraint.activate(noDataLabelConstraints)
        } else {
            noDataLabel.removeFromSuperview()
        }
    }
    
}

extension WatchlistsVC {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return watchlists.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WatchlistCell.reuseIdentifier, for: indexPath) as! WatchlistCell
        let watchlist = watchlists[indexPath.item]
        cell.setImageUnavailable()
//        cell.image = UIImage(named: "avengers_1")
        cell.title = watchlist.title
        cell.subtitle = "X of XX watched"
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let watchlist = watchlists[indexPath.item]
        performSegue(withIdentifier: "WatchlistVC", sender: watchlist)
    }
    
}

extension WatchlistsVC: WatchlistOperationDelegate {
    
    func didCreateWatchlist(_ id: UUID) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let watchlist = LocalDatabase.shared.fetchWatchlist(id) else { return }
            self?.performSegue(withIdentifier: "WatchlistVC", sender: watchlist)
        }
    }
    
}

