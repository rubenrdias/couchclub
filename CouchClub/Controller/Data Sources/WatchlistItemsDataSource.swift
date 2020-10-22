//
//  WatchlistItemsDataSource.swift
//  CouchClub
//
//  Created by Ruben Dias on 05/06/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class WatchlistItemsDataSource: NSObject {
    
    private enum Section: String {
        case statistics = "statistics"
        case movies = "movies"
        case shows = "shows"
    }
    
    weak var delegate: ItemDataSourceDelegate?
    weak var collectionView: UICollectionView!
    
    weak var watchlist: Watchlist!
    private var items: [Item] {
        get {
            let watchlistItems = watchlist.items?.allObjects as? [Item]
            return watchlistItems?.sorted { $0.title < $1.title } ?? []
        }
    }
    
    private var sectionHeaders: [Section] = [.statistics]
    
    private var itemsPerRow: Int = 1
    private var usableWidth: CGFloat = 0
    
    private var footerCellID = "footerCellID"

    init(watchlist: Watchlist, collectionView: UICollectionView, delegate: ItemDataSourceDelegate? = nil) {
        super.init()
        self.watchlist = watchlist
        self.collectionView = collectionView
        self.delegate = delegate
        
        setupObservers()
        registerViews()
        setupCollectionViewLayout(collectionView.bounds.size)
        setupHeaders()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(watchlistItemsUpdated), name: .watchlistChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(itemWasUpdated), name: .itemWatchedStatusChanged, object: nil)
    }
    
    private func registerViews() {
        collectionView.register(SmallHeaderCVCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SmallHeaderCVCell.reuseIdentifier)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerCellID)
        collectionView.register(TextCVCell.self, forCellWithReuseIdentifier: TextCVCell.reuseIdentifier)
        collectionView.register(HighlightCVCell.self, forCellWithReuseIdentifier: HighlightCVCell.reuseIdentifier)
        collectionView.register(ItemCell.self, forCellWithReuseIdentifier: ItemCell.reuseIdentifier)
    }
    
    private func setupHeaders() {
        switch watchlist.type {
        case ItemType.series.rawValue:
            sectionHeaders.append(.shows)
        default:
            sectionHeaders.append(.movies)
        }
    }
    
    @objc private func watchlistItemsUpdated(_ notification: Notification) {
        guard let info = notification.userInfo else { return }
        
        if let watchlistID = info["watchlistID"] as? UUID, watchlistID == watchlist.id {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
    
    @objc private func itemWasUpdated(_ notification: Notification) {
        guard let item = notification.userInfo?["item"] as? Item else { return }
        
        if items.contains(item) {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadItems(at: [.init(item: 0, section: 1)])
            }
        }
    }
    
}

extension WatchlistItemsDataSource: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func setupCollectionViewLayout(_ size: CGSize) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            switch UIDevice.current.orientation {
            case .portrait, .portraitUpsideDown:
                itemsPerRow = 3
            default:
                itemsPerRow = 5
            }
        } else {
            itemsPerRow = 2
        }

        collectionView.contentInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        usableWidth = size.width - 2 * 16
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        3
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if indexPath.section > 0 {
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SmallHeaderCVCell.reuseIdentifier, for: indexPath) as! SmallHeaderCVCell
                headerView.text = sectionHeaders[indexPath.section - 1].rawValue
                headerView.showButtons = (indexPath.section == 2)
                return headerView
            }
        } else {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerCellID, for: indexPath)
            return footerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return .zero
        } else {
            return .init(width: usableWidth, height: 44)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == 0 {
            return .init(width: usableWidth, height: 16)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section <= 1 {
            return 1
        } else {
            return items.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextCVCell.reuseIdentifier, for: indexPath) as! TextCVCell
            cell.text = watchlist.title
            return cell
        } else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HighlightCVCell.reuseIdentifier, for: indexPath) as! HighlightCVCell
            cell.highlightLeft = (watchlist.itemsWatchedString(withDescription: false), "Watched")
            if watchlist.type == ItemType.movie.rawValue {
                cell.highlightRight = (watchlist.screenTimeString(), "Total screen time")
            } else {
                cell.highlightRight = (watchlist.averageRatingString(), "Average rating")
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCell.reuseIdentifier, for: indexPath) as! ItemCell
            cell.delegate = self
            cell.item = items[indexPath.item]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section > 1 {
            let item = items[indexPath.item]
            delegate?.didTapItem(item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            let size = CGSize(width: usableWidth, height: 80)
            let attributes = [NSAttributedString.Key.font: UIFont.translatedFont(for: .title2, .semibold)]
            let estimatedFrame = NSString(string: watchlist.title).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            return .init(width: usableWidth, height: estimatedFrame.height)
        }
        else if indexPath.section == 1 {
            return .init(width: usableWidth, height: 70)
        } else {
            let width: CGFloat = (usableWidth - CGFloat(itemsPerRow - 1) * 16) / CGFloat(itemsPerRow)
            let height: CGFloat = width * 3/2
            return .init(width: width, height: height)
        }
    }
    
}

extension WatchlistItemsDataSource: ItemOperationDelegate {
    
    func didTapSeen(_ item: Item) {
        delegate?.didTapItemSeen(item)
    }
    
}
