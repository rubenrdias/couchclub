//
//  HighlightTVCell.swift
//  CouchClub
//
//  Created by Ruben Dias on 28/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class HighlightTVCell: UITableViewCell {
    
    static let reuseIdentifier = "HighlightTVCell"
    
    // (title, subtitle)
    var highlightLeft = ("", "") {
        didSet { updateText(0) }
    }
    var highlightRight = ("", "") {
        didSet { updateText(1) }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor.colorAsset(.dynamicBackground)
        
        setupContainers()
        setupText()
    }
    
    private lazy var highlightLeftContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.colorAsset(.dynamicBackgroundHighlight)
        view.clipsToBounds = true
        view.layer.cornerRadius = 4
        return view
    }()
    
    private lazy var highlightRightContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.colorAsset(.dynamicBackgroundHighlight)
        view.clipsToBounds = true
        view.layer.cornerRadius = 4
        return view
    }()
    
    private func setupContainers() {
        contentView.addSubview(highlightLeftContainer)
        contentView.addSubview(highlightRightContainer)
        NSLayoutConstraint.activate([            
            highlightLeftContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            highlightLeftContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            highlightLeftContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            highlightLeftContainer.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -8),
            
            highlightRightContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            highlightRightContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            highlightRightContainer.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 8),
            highlightRightContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
    
    private lazy var leftStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [leftSubtitleLabel, leftTitleLabel])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 4
        return sv
    }()
    
    private lazy var leftTitleLabel: UILabel = {
        let lbl = UILabel.standardLabel(.subheadline, .bold, UIColor.systemOrange)
        return lbl
    }()
    
    private lazy var leftSubtitleLabel: UILabel = {
        let lbl = UILabel.standardLabel(.footnote, .regular, UIColor.colorAsset(.dynamicLabelSecondary))
        return lbl
    }()
    
    private lazy var rightStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [rightSubtitleLabel, rightTitleLabel])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 4
        return sv
    }()
    
    private lazy var rightTitleLabel: UILabel = {
        let lbl = UILabel.standardLabel(.subheadline, .bold, UIColor.systemOrange)
        return lbl
    }()
    
    private lazy var rightSubtitleLabel: UILabel = {
        let lbl = UILabel.standardLabel(.footnote, .regular, UIColor.colorAsset(.dynamicLabelSecondary))
        return lbl
    }()
    
    private func setupText() {
        highlightLeftContainer.addSubview(leftStackView)
        highlightRightContainer.addSubview(rightStackView)
        
        NSLayoutConstraint.activate([
            leftStackView.leadingAnchor.constraint(equalTo: highlightLeftContainer.leadingAnchor, constant: 16),
            leftStackView.trailingAnchor.constraint(equalTo: highlightLeftContainer.trailingAnchor, constant: -16),
            leftStackView.centerYAnchor.constraint(equalTo: highlightLeftContainer.centerYAnchor),
            
            rightStackView.leadingAnchor.constraint(equalTo: highlightRightContainer.leadingAnchor, constant: 16),
            rightStackView.trailingAnchor.constraint(equalTo: highlightRightContainer.trailingAnchor, constant: -16),
            rightStackView.centerYAnchor.constraint(equalTo: highlightRightContainer.centerYAnchor)
        ])
    }
    
    private func updateText(_ side: Int) {
        if side == 0 {
            leftTitleLabel.text = highlightLeft.0
            leftSubtitleLabel.text = highlightLeft.1
        } else {
            rightTitleLabel.text = highlightRight.0
            rightSubtitleLabel.text = highlightRight.1
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
