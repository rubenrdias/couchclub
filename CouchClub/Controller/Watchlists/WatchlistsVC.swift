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
    lazy var dataSource = WatchlistsDataSource(collectionView: collectionView, delegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Watchlists"
        
        configureCollectionView()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        dataSource.setupCollectionViewLayout(size)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !FirebaseService.shared.currentUserExists {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [unowned self] in
                self.coordinator?.showLogin()
            }
        }
    }
    
    private func configureCollectionView() {
        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource
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
    
    func didCreateWatchlist(_ id: UUID) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let watchlist = LocalDatabase.shared.fetchWatchlist(id) else { return }
            self?.coordinator?.showDetail(watchlist)
        }
    }
    
}

extension WatchlistsVC: WatchlistsDataSourceDelegate {
    
    func didRefreshData() {
        if dataSource.isEmpty {
            collectionView.alwaysBounceVertical = false
            navigationItem.rightBarButtonItem = nil
            view.addSubview(noDataLabel)
            view.addSubview(createWatchlistButton)
            NSLayoutConstraint.activate(noDataLabelConstraints)
            NSLayoutConstraint.activate(createWatchlistButtonConstraints)
        } else {
            collectionView.alwaysBounceVertical = true
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createWatchlist))
            noDataLabel.removeFromSuperview()
            createWatchlistButton.removeFromSuperview()
        }
    }
    
    func didTapWatchlist(_ watchlist: Watchlist) {
        coordinator?.showDetail(watchlist)
    }
    
    
}
