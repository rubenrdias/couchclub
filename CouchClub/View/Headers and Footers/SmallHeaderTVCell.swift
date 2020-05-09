//
//  SmallHeaderTVCell.swift
//  CouchClub
//
//  Created by Ruben Dias on 09/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class SmallHeaderTVCell: UITableViewHeaderFooterView {
    
    static var reuseIdentifier = "SmallHeaderTVCell"
    
    var text: String = "" {
        didSet { label.text = text.uppercased() }
    }
    var useCenteredText: Bool = false {
        didSet { label.textAlignment = useCenteredText ? .center : .left }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        backgroundView = UIView(frame: self.bounds)
        backgroundView?.backgroundColor = .clear
        
        setupLabel()
    }
    
    private lazy var label: UILabel = {
        let lbl = UILabel.standardLabel(.footnote, .regular, .colorAsset(.dynamicLabelSecondary))
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private func setupLabel() {
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalToSystemSpacingBelow: label.firstBaselineAnchor, multiplier: 1),
            contentView.leadingAnchor.constraint(equalToSystemSpacingAfter: label.leadingAnchor, multiplier: 1),
            label.trailingAnchor.constraint(equalToSystemSpacingAfter: contentView.trailingAnchor, multiplier: 1),
            label.lastBaselineAnchor.constraint(equalToSystemSpacingBelow: contentView.bottomAnchor, multiplier: 1)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
