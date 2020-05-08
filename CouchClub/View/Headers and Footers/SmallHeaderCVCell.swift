//
//  HeaderCVCell.swift
//  CouchClub
//
//  Created by Ruben Dias on 26/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class SmallHeaderCVCell: UICollectionReusableView {
    
    static let reuseIdentifier = "SmallHeaderCVCell"
    
    weak var delegate: HeaderButtonsDelegate?
    
    var text: String = "" {
        didSet { updateText() }
    }
    
    var showButtons = false {
        didSet { toggleButtonVisibility() }
    }
    
    var activeButton: Int = 1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupButtons()
        toggleButtonVisibility()
        setupText()
    }
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [listButton, thumbnailsButton])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        return sv
    }()
    
    private lazy var listButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.imageEdgeInsets = .init(top: 5.5, left: 5.5, bottom: 5.5, right: 5.5)
        btn.setImage(UIImage.iconAsset(.list), for: .normal)
        btn.tintColor = .colorAsset(.dynamicLabelSecondary)
        btn.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
        btn.tag = 0
        return btn
    }()
    
    private lazy var thumbnailsButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.imageEdgeInsets = .init(top: 6.5, left: 6.5, bottom: 6.5, right: 6.5)
        btn.setImage(UIImage.iconAsset(.thumbnails), for: .normal)
        btn.tintColor = UIColor.systemOrange
        btn.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
        btn.tag = 1
        return btn
    }()
    
    private func setupButtons() {
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: listButton, attribute: .height, relatedBy: .equal, toItem: listButton, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: thumbnailsButton, attribute: .height, relatedBy: .equal, toItem: thumbnailsButton, attribute: .width, multiplier: 1, constant: 0),
            listButton.heightAnchor.constraint(equalTo: heightAnchor),
            thumbnailsButton.heightAnchor.constraint(equalTo: heightAnchor),
            
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private lazy var textLabel: UILabel = {
        let lbl = UILabel.standardLabel(.footnote, .regular, .colorAsset(.dynamicLabelSecondary))
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private func setupText() {
        addSubview(textLabel)
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: topAnchor),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: stackView.leadingAnchor)
        ])
    }
    
    private func updateText() {
        textLabel.text = text.uppercased()
    }
    
    private func toggleButtonVisibility() {
        listButton.isHidden = !showButtons
        thumbnailsButton.isHidden = !showButtons
    }
    
    @objc private func buttonTapped(sender: UIButton) {
        if activeButton == sender.tag { return }
        
        activeButton = sender.tag
        if sender.tag == 0 {
            listButton.tintColor = UIColor.systemOrange
            thumbnailsButton.tintColor = .colorAsset(.dynamicLabel)
            delegate?.didTapListButton()
        } else {
            thumbnailsButton.tintColor = UIColor.systemOrange
            listButton.tintColor = .colorAsset(.dynamicLabelSecondary)
            delegate?.didTapThumbnailsButton()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
