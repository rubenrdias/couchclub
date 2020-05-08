//
//  TextCVCell.swift
//  CouchClub
//
//  Created by Ruben Dias on 01/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class TextCVCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TextCVCell"
    
    var text: String = "" {
        didSet { titleLabel.text = text }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupText()
    }
    
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel.standardLabel(.title2, .bold, .colorAsset(.dynamicLabel))
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private func setupText() {
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
