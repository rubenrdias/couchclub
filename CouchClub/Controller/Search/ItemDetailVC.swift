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
        case releasedOn = "released on"
        case runtime = "runtime"
    }
    
    var tableView: UITableView!
    
    var item: Item!
    private var attributes = [Attribute]()
    private var highlightAttributes = [Attribute]()
    
    let headerCellID = "headerCellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) { isModalInPresentation = true }
        
        if item.isKind(of: Movie.self) {
            attributes = [.plot, .actors, .boxOffice, .director, .writers, .producer]
            highlightAttributes = [.releasedOn, .runtime]
        } else {
            attributes = [.plot, .actors, .writers, .year]
            highlightAttributes = [.releasedOn, .runtime]
        }
        
        setupToolbar()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    deinit {
        print("-- DEINIT -- Item Detail VC")
    }
    
    @IBAction func startChatroomTapped(_ sender: UIBarButtonItem) {
        // TODO: start chatroom...
    }
    
    @objc private func addToWatchlist() {
        // TODO: add to watchlist
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(ItemDetailHeaderTVCell.self, forHeaderFooterViewReuseIdentifier: ItemDetailHeaderTVCell.reuseIdentifier)
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: headerCellID)
        tableView.register(HighlightTVCell.self, forCellReuseIdentifier: HighlightTVCell.reuseIdentifier)
        
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func setupToolbar() {
        let spaceButton1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let spaceButton2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let addButton = UIBarButtonItem(title: "Add to Watchlist", style: .plain, target: self, action: #selector(addToWatchlist))
        
        toolbarItems = [spaceButton1, addButton, spaceButton2]
        navigationController?.toolbar.layoutIfNeeded()
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
            headerView.fillDetails(item)
            return headerView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let view = UIView()
            view.backgroundColor = UIColor.colorAsset(.dynamicBackground)
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
            cell.contentView.backgroundColor = UIColor.colorAsset(.dynamicBackground)
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
