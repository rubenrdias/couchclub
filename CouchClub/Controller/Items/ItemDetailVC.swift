//
//  File.swift
//  CouchClub
//
//  Created by Ruben Dias on 27/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class ItemDetailVC: UIViewController {
    
    private enum Attribute: String {
        case actors = "actors"
        case boxOffice = "box office"
        case director = "director"
        case plot = "plot"
        case producer = "producer"
        case writers = "writers"
        case year = "year"
        case totalSeasons = "seasons"
        case releasedOn = "Released on"
        case runtime = "Runtime"
    }
    
    weak var delegate: ItemOperationDelegate?
    weak var selectionDelegate: ItemSelectionDelegate?
    
    private var tableView: UITableView!
    @IBOutlet weak var actionButton: UIButton!
    
    var item: Item!
    var watchlist: Watchlist?
    private var shouldAddToList = true
    
    private var attributes = [Attribute]()
    private var highlightAttributes = [Attribute]()
    
    private let headerCellID = "headerCellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .colorAsset(.dynamicBackground)
        
        if #available(iOS 13.0, *) { isModalInPresentation = true }
        
        if item.isKind(of: Movie.self) {
            attributes = [.plot, .actors, .boxOffice, .director, .writers, .producer]
            highlightAttributes = [.releasedOn, .runtime]
        } else {
            attributes = [.plot, .actors, .writers, .year]
            highlightAttributes = [.releasedOn, .runtime]
        }
        
        setupTableView()
        setupActionButton()
    }
    
    deinit {
        print("-- DEINIT -- Item Detail VC")
    }
    
    @IBAction func startChatroomTapped(_ sender: UIBarButtonItem) {
        // TODO: start chatroom...
    }
    
    @IBAction func watchlistButtonTapped(_ sender: UIButton) {
        if let watchlist = watchlist {
            if shouldAddToList {
                DataCoordinator.shared.addToWatchlist([item], watchlist) { [weak self] error in
                    if let error = error {
                        print("Failed to add \(self?.item.title ?? "item") to watchlist: \(error.localizedDescription)")
                    }
                    
                    let ac = Alerts.simpleAlert(title: "Added!", message: "The watchlist has been updated.") { [weak self] _ in
                        self?.navigationController?.popViewController(animated: true)
                    }
                    
                    self?.present(ac, animated: true, completion: nil)
                }
            } else {
                DataCoordinator.shared.removeFromWatchlist([item], watchlist) { [weak self] error in
                    if let error = error {
                        print("Failed to remove \(self?.item.title ?? "item") from watchlist: \(error.localizedDescription)")
                    }
                    
                    let ac = Alerts.simpleAlert(title: "Removed!", message: "The watchlist has been updated.") { [weak self] _ in
                        self?.navigationController?.popViewController(animated: true)
                    }
                    
                    self?.present(ac, animated: true, completion: nil)
                }
            }
        } else {
            selectionDelegate?.didSelectItem(item.id)
        }
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .grouped)
        tableView.contentInset = .init(top: 0, left: 0, bottom: 2 * 32 + 56, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(ItemDetailHeaderTVCell.self, forHeaderFooterViewReuseIdentifier: ItemDetailHeaderTVCell.reuseIdentifier)
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: headerCellID)
        tableView.register(HighlightTVCell.self, forCellReuseIdentifier: HighlightTVCell.reuseIdentifier)
        
        tableView.backgroundColor = .colorAsset(.dynamicBackground)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func setupActionButton() {
        if let watchlist = watchlist {
            if let items = watchlist.items?.allObjects as? [Item] {
                if items.contains(item) {
                    shouldAddToList = false
                    actionButton.setTitle("Remove from Watchlist", for: .normal)
                    actionButton.backgroundColor = UIColor.init(white: 0.4, alpha: 1)
                }
            } else {
                actionButton.setTitle("Add to Watchlist", for: .normal)
            }
        } else {
            let type = item.isKind(of: Movie.self) ? ItemType.movie.rawValue : "Show"
            actionButton.setTitle("Select this \(type)", for: .normal)
        }
        
        actionButton.layer.cornerRadius = 4
        actionButton.clipsToBounds = true
        view.bringSubviewToFront(actionButton)
    }
    
    private func attributedText(_ attribute: Attribute) -> NSMutableAttributedString {
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.translatedFont(for: .footnote, .regular),
            .foregroundColor: UIColor.colorAsset(.dynamicLabelSecondary)
        ]
        let attributedText = NSMutableAttributedString(string: "\(attribute.rawValue.uppercased())\n", attributes: headerAttributes)
        
        attributedText.append(NSAttributedString(string: text(attribute)))
        
        return attributedText
    }
    
    private func text(_ attribute: Attribute) -> String {
        switch attribute {
            case .actors:
                return item.actors
            case .boxOffice:
                if let movie = item as? Movie {
                    return movie.boxOffice
                }
            case .director:
                return item.director
            case .plot:
                return item.plot
            case .producer:
                if let movie = item as? Movie {
                    return movie.production
                }
            case .writers:
                return item.writer
            case .year:
                return item.year
            case .totalSeasons:
                if let show = item as? Show, let seasons = Int(show.totalSeasons) {
                    return "\(seasons) season\(seasons == 1 ? "" : "s")"
                }
        case .releasedOn:
            return item.released
        case .runtime:
            return item.runtime
        }
        return ""
    }
    
}

extension ItemDetailVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ItemDetailHeaderTVCell.reuseIdentifier) as! ItemDetailHeaderTVCell
            headerView.delegate = self
            headerView.item = item
            return headerView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let view = UIView()
            view.backgroundColor = .colorAsset(.dynamicBackground)
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if UIDevice.current.userInterfaceIdiom == .pad {
                return 250 + 2 * 16
            } else {
                return 150 + 2 * 16
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 8
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return attributes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: HighlightTVCell.reuseIdentifier, for: indexPath) as! HighlightTVCell
            let leftAttribute = highlightAttributes[0]
            let rightAttribute = highlightAttributes[1]
            cell.highlightLeft = (text(leftAttribute), leftAttribute.rawValue)
            cell.highlightRight = (text(rightAttribute), rightAttribute.rawValue)
            return cell
        } else {
            let cell = UITableViewCell()
            cell.contentView.backgroundColor = .colorAsset(.dynamicBackground)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.attributedText = attributedText(attributes[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 70
        } else {
            return UITableView.automaticDimension
        }
    }
    
}

extension ItemDetailVC: ItemOperationDelegate {
    
    func didTapSeen(_ item: Item) {
        delegate?.didTapSeen(item)
    }
    
}
