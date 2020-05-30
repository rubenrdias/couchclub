//
//  ViewController.swift
//  CouchClub
//
//  Created by Ruben Dias on 25/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth

class WatchlistsVC: UICollectionViewController, Storyboarded {
    
    weak var coordinator: WatchlistsCoordinator?
    
    private var itemsPerRow: Int = 1
    private var usableWidth: CGFloat = 0
    
    var watchlists = [Watchlist]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Watchlists"
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchData), name: .watchlistsDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateWatchlist), name: .watchlistDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(itemSeenStatusUpdated), name: .itemWatchedStatusChanged, object: nil)
        
        collectionView.register(WatchlistCell.self, forCellWithReuseIdentifier: WatchlistCell.reuseIdentifier)
        
        let size = CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
        setupCollectionViewLayout(size)
        fetchData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setupCollectionViewLayout(size)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if FirebaseService.currentUserID == nil {
            performSegue(withIdentifier: "LoginVC", sender: nil)
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
    
    @objc private func updateWatchlist(_ notification: Notification) {
        guard let watchlistID = notification.userInfo?["watchlistID"] as? UUID else { return }
        
        if let index = watchlists.firstIndex(where: { $0.id == watchlistID }) {
            collectionView.reloadItems(at: [.init(item: index, section: 0)])
        }
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
            noDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
    }()
    
    private lazy var noDataText: NSMutableAttributedString = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 8
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 1.15
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.colorAsset(.dynamicLabel),
            .font: UIFont.translatedFont(for: .title2, .semibold),
            .paragraphStyle: paragraphStyle
        ]
        let attributtedString = NSMutableAttributedString(string: "No watchlists found...\n", attributes: titleAttributes)
        
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.colorAsset(.dynamicLabelSecondary),
            .font: UIFont.translatedFont(for: .subheadline, .regular),
            .paragraphStyle: paragraphStyle
        ]
        attributtedString.append(NSAttributedString(string: "You can use Watchlists to track movies or shows you want to watch.", attributes: subtitleAttributes))
        
        return attributtedString
    }()
    
    private lazy var createWatchlistButton: RoundedButton = {
        let btn = RoundedButton()
        btn.makeCTA()
        btn.setTitle("Create Watchlist", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(createWatchlist), for: .touchUpInside)
        return btn
    }()
    
    @objc private func createWatchlist() {
        coordinator?.newWatchlist()
    }
    
    private lazy var createWatchlistButtonConstraints: [NSLayoutConstraint] = {
        return [
            createWatchlistButton.heightAnchor.constraint(equalToConstant: 56),
            createWatchlistButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            createWatchlistButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createWatchlistButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32)
        ]
    }()
    
    private func evaluateDataAvailable() {
        if watchlists.isEmpty {
            navigationItem.rightBarButtonItem = nil
            view.addSubview(noDataLabel)
            view.addSubview(createWatchlistButton)
            NSLayoutConstraint.activate(noDataLabelConstraints)
            NSLayoutConstraint.activate(createWatchlistButtonConstraints)
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createWatchlist))
            noDataLabel.removeFromSuperview()
            createWatchlistButton.removeFromSuperview()
        }
    }
        
    @objc private func itemSeenStatusUpdated(_ notification: Notification) {
        guard let item = notification.userInfo?["item"] as? Item else { return }

        // TODO: reload watchlist cells containing the updated item
    }
    
    private func calculateItemsWatched(_ watchlist: Watchlist) -> String {
        guard let items = watchlist.items?.allObjects as? [Item] else { return "0 of 0 \(watchlist.type)s watched" }
        let watched = items.reduce(0) { $0 + ($1.watched ? 1 : 0) }
        
        let typeString = watchlist.type == ItemType.movie.rawValue ? ItemType.movie.rawValue : "show"
        
        return "\(watched) of \(items.count) \(typeString)\(items.count == 1 ? "" : "s") watched"
    }
    
    func didCreateWatchlist(_ id: UUID) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let watchlist = LocalDatabase.shared.fetchWatchlist(id) else { return }
            self?.coordinator?.showDetail(watchlist)
        }
    }
    
}

extension WatchlistsVC {
    
    private func setupCollectionViewLayout(_ size: CGSize) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            switch UIDevice.current.orientation {
            case .portrait, .portraitUpsideDown:
                itemsPerRow = 2
            default:
                itemsPerRow = 3
            }
            collectionView.contentInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        } else {
            itemsPerRow = 1
            collectionView.contentInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        }
        
        usableWidth = size.width - 2 * 16
        updateItemSize()
    }
    
    private func updateItemSize() {
        let width: CGFloat = (usableWidth - CGFloat(itemsPerRow - 1) * 16) / CGFloat(itemsPerRow)
        let height: CGFloat = width * 11/16
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = .init(width: width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return watchlists.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WatchlistCell.reuseIdentifier, for: indexPath) as! WatchlistCell
        let watchlist = watchlists[indexPath.item]
        cell.watchlist = watchlist
        cell.subtitle = calculateItemsWatched(watchlist)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let watchlist = watchlists[indexPath.item]
        coordinator?.showDetail(watchlist)
    }
    
}
