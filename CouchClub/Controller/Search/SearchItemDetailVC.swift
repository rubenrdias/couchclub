//
//  File.swift
//  CouchClub
//
//  Created by Ruben Dias on 27/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class SearchItemDetailVC: UIViewController {
    
    private enum Attribute: String {
        case actors = "actors"
        case boxOffice = "box office"
        case director = "director"
        case plot = "plot"
        case producer = "producer"
        case writers = "writers"
    }
    
    var tableView: UITableView!
    
    var movie: Movie!
    private let attributes: [Attribute] = [.plot, .actors, .boxOffice, .director, .writers, .producer]
    
    let headerCellID = "headerCellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) { isModalInPresentation = true }
        
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
            return movie.actors
        case .boxOffice:
            return movie.boxOffice
        case .director:
            return movie.director
        case .plot:
            return movie.plot
        case .producer:
            return movie.producer
        case .writers:
            return movie.writer
        }
    }
    
}

extension SearchItemDetailVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ItemDetailHeaderTVCell.reuseIdentifier) as! ItemDetailHeaderTVCell
            headerView.updateText(movie)
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
            cell.highlightLeft = (movie.released, "Released on")
            cell.highlightRight = (movie.runtime, "Runtime")
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
