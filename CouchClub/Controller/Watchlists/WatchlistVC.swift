//
//  WatchlistVC.swift
//  CouchClub
//
//  Created by Ruben Dias on 30/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class WatchlistVC: UICollectionViewController {
    
    private enum Section: String {
        case statistics = "statistics"
        case movies = "movies"
        case shows = "shows"
    }
    
    private var itemsPerRow: Int = 1
    private var usableWidth: CGFloat = 0
    
    private var sectionHeaders: [Section] = [.statistics]
    
    var watchlist: Watchlist! {
        didSet {
            if let items = watchlist.items?.allObjects as? [Item] {
                watchlistItems = items.sorted { $0.title < $1.title }
            }
            
            switch watchlist.type {
            case ItemType.series.rawValue:
                    sectionHeaders.append(.shows)
                default:
                    sectionHeaders.append(.movies)
            }
        }
    }
    private var watchlistItems = [Item]()
    
    private var footerCellID = "footerCellID"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(watchlistItemsUpdated), name: .watchlistDidChange, object: nil)
        
        collectionView.register(SmallHeaderCVCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SmallHeaderCVCell.reuseIdentifier)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerCellID)
        collectionView.register(TextCVCell.self, forCellWithReuseIdentifier: TextCVCell.reuseIdentifier)
        collectionView.register(HighlightCVCell.self, forCellWithReuseIdentifier: HighlightCVCell.reuseIdentifier)
        collectionView.register(ItemCell.self, forCellWithReuseIdentifier: ItemCell.reuseIdentifier)
        
        let size = CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
        setupCollectionViewLayout(size)
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setupCollectionViewLayout(size)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchVC" {
            guard let navController = segue.destination as? UINavigationController else { return }
            guard let searchVC = navController.viewControllers.first as? SearchVC else { return }
            searchVC.watchlist = watchlist
        } else if segue.identifier == "ItemDetailVC" {
            guard let item = sender as? Item else { return }
            guard let detailVC = segue.destination as? ItemDetailVC else { return }
            detailVC.hidesBottomBarWhenPushed = true
            detailVC.delegate = self
            detailVC.item = item
            detailVC.watchlist = watchlist
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("-- DEINIT -- Watchlist VC")
    }
    
    @IBAction func moreButtonTapped(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.view.tintColor = .colorAsset(.dynamicLabel)
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        ac.addAction(UIAlertAction(title: "Delete Watchlist", style: .destructive) { [weak self] _ in
            let deletionAlert = Alerts.deletionAlert(title: "Delete Watchlist?", message: "This action is irreversible.") { _ in
                guard let watchlist = self?.watchlist else { return }
                DataCoordinator.shared.deleteWatchlist(watchlist) { error in
                    if let error = error {
                        // TODO: handle errors
                        print("Error when deleting watchlist: ", error.localizedDescription)
                    } else {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
            
            self?.present(deletionAlert, animated: true, completion: nil)
        })
                
        ac.popoverPresentationController?.barButtonItem = sender
        present(ac, animated: true, completion: nil)
    }
    
    private func setupCollectionViewLayout(_ size: CGSize) {
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
    }
    
    @objc private func watchlistItemsUpdated(_ notification: Notification) {
        guard let info = notification.userInfo else { return }
        
        if let watchlistID = info["watchlistID"] as? UUID, watchlistID == watchlist.id {
            if let items = watchlist.items?.allObjects as? [Item] {
                watchlistItems = items.sorted { $0.title < $1.title }
                DispatchQueue.main.async { [weak self] in
                    self?.collectionView.reloadData()
                }
            }
        }
    }
    
    private func calculateItemsWatched() -> String {
        guard !watchlistItems.isEmpty else { return "N/A" }
        let watched = watchlistItems.reduce(0) { $0 + ($1.watched ? 1 : 0) }
        return "\(watched) of \(watchlistItems.count)"
    }
    
    private func calculateScreenTime() -> String {
        guard !watchlistItems.isEmpty else { return "N/A" }
        
        var timeInMinutes = 0
        watchlistItems.forEach {
            if $0.runtime == "N/A" { return }
            let minutesString = $0.runtime.split(separator: " ")[0]
            if let minutes = Int(minutesString) {
                timeInMinutes += minutes
            }
        }
        
        let hours = Int(floor(Double(timeInMinutes / 60)))
        let minutes = timeInMinutes - 60 * hours
        
        if timeInMinutes == 0 {
            return "N/A"
        } else if hours == 0 {
            return "\(minutes) min"
        } else {
            var string = "\(hours) h"
            if minutes > 0 {
                string.append(" \(minutes) min")
            }
            return string
        }
    }
    
    private func calculateAverageRating() -> String {
        guard !watchlistItems.isEmpty else { return "N/A" }
        
        var globalRating: Double = 0
        watchlistItems.forEach {
            if let rating = Double($0.imdbRating) {
                globalRating += rating
            }
        }
        
        globalRating = globalRating / Double(watchlistItems.count)
        
        if globalRating == 0 {
            return "N/A"
        } else {
            return "\(String(format: "%.1f", globalRating))/10"
        }
    }

}

extension WatchlistVC: UICollectionViewDelegateFlowLayout {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        3
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if indexPath.section > 0 {
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SmallHeaderCVCell.reuseIdentifier, for: indexPath) as! SmallHeaderCVCell
                headerView.text = sectionHeaders[indexPath.section - 1].rawValue
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
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section <= 1 {
            return 1
        } else {
            return watchlistItems.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextCVCell.reuseIdentifier, for: indexPath) as! TextCVCell
            cell.text = watchlist.title
            return cell
        } else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HighlightCVCell.reuseIdentifier, for: indexPath) as! HighlightCVCell
            cell.highlightLeft = (calculateItemsWatched(), "Watched")
            if watchlist.type == ItemType.movie.rawValue {
                cell.highlightRight = (calculateScreenTime(), "Total screen time")
            } else {
                cell.highlightRight = (calculateAverageRating(), "Average rating")
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCell.reuseIdentifier, for: indexPath) as! ItemCell
            cell.delegate = self
            cell.item = watchlistItems[indexPath.item]
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section > 1 {
            let item = watchlistItems[indexPath.item]
            performSegue(withIdentifier: "ItemDetailVC", sender: item)
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

extension WatchlistVC: ItemOperationDelegate {
    
    func didTapSeen(_ item: Item) {
        DataCoordinator.shared.toggleWatched(item)
        
        if let highlightCell = collectionView.cellForItem(at: .init(item: 0, section: 1)) as? HighlightCVCell {
            highlightCell.highlightLeft = (calculateItemsWatched(), "Watched")
        }
    }
    
}
