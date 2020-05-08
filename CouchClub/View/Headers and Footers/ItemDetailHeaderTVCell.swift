//
//  ItemDetailHeaderTVCell.swift
//  CouchClub
//
//  Created by Ruben Dias on 27/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class ItemDetailHeaderTVCell: UITableViewHeaderFooterView {
    
    weak var delegate: ItemOperationDelegate?
    
    static let reuseIdentifier = "ItemDetailHeaderTVCell"
    
    var item: Item! {
        didSet { updateInfo() }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .colorAsset(.dynamicBackground)
        
        setupImage()
        setupText()
    }
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .lightGray
        iv.layer.cornerRadius = 4
        iv.clipsToBounds = true
        return iv
    }()
    
    private func setupImage() {
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .width, multiplier: 3/2, constant: 0),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        ])
    }
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, genreLabel, spacer1, awardsLabel, spacer2, ratingsContainerView])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.alignment = .fill
        return sv
    }()
    
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel.standardLabel(.title2, .bold, .colorAsset(.dynamicLabel))
        lbl.numberOfLines = 2
        lbl.adjustsFontSizeToFitWidth = true
        return lbl
    }()
    
    private lazy var genreLabel: UILabel = {
        let lbl = UILabel.standardLabel(.footnote, .regular, .colorAsset(.dynamicLabelSecondary))
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private lazy var awardsLabel: UILabel = {
        let lbl = UILabel.standardLabel(.footnote, .regular, .colorAsset(.dynamicLabelSecondary))
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private lazy var spacer1: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var spacer2: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var ratingsContainerView = UIView()
    
    private lazy var imdbIconView: UIImageView = {
        let view = UIImageView(image: UIImage.iconAsset(.imdb))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var ratingsLabel: UILabel = {
        let lbl = UILabel.standardLabel(.footnote, .regular, .colorAsset(.dynamicLabelSecondary))
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private lazy var seenButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(seenButtonTapped), for: .touchUpInside)
        btn.imageEdgeInsets = .init(top: 2, left: 2, bottom: 2, right: 2)
        btn.setImage(UIImage.iconAsset(.checkmark), for: .normal)
        btn.tintColor = .colorAsset(.dynamicLabelSecondary)
        return btn
    }()
    
    private lazy var favoriteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        btn.imageEdgeInsets = .init(top: 2, left: 2, bottom: 2, right: 2)
        btn.setImage(UIImage.iconAsset(.heart), for: .normal)
        btn.tintColor = .colorAsset(.dynamicLabelSecondary)
        return btn
    }()
    
    private func setupText() {
        ratingsContainerView.addSubview(imdbIconView)
        ratingsContainerView.addSubview(ratingsLabel)
        ratingsContainerView.addSubview(seenButton)
//        ratingsContainerView.addSubview(favoriteButton)
        
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            ratingsContainerView.heightAnchor.constraint(equalToConstant: 30),
            
            imdbIconView.heightAnchor.constraint(equalToConstant: 30),
            imdbIconView.leadingAnchor.constraint(equalTo: ratingsContainerView.leadingAnchor),
            imdbIconView.centerYAnchor.constraint(equalTo: ratingsContainerView.centerYAnchor),
            
            ratingsLabel.leadingAnchor.constraint(equalTo: imdbIconView.trailingAnchor, constant: 8),
            ratingsLabel.centerYAnchor.constraint(equalTo: ratingsContainerView.centerYAnchor),
            
            NSLayoutConstraint(item: seenButton, attribute: .height, relatedBy: .equal, toItem: seenButton, attribute: .width, multiplier: 1, constant: 0),
//            NSLayoutConstraint(item: favoriteButton, attribute: .height, relatedBy: .equal, toItem: favoriteButton, attribute: .width, multiplier: 1, constant: 0),

            seenButton.heightAnchor.constraint(equalTo: ratingsContainerView.heightAnchor),
            seenButton.centerYAnchor.constraint(equalTo: ratingsContainerView.centerYAnchor),
            seenButton.trailingAnchor.constraint(equalTo: ratingsContainerView.trailingAnchor),
//            seenButton.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor),
//            favoriteButton.heightAnchor.constraint(equalTo: ratingsContainerView.heightAnchor),
//            favoriteButton.centerYAnchor.constraint(equalTo: ratingsContainerView.centerYAnchor),
//            favoriteButton.trailingAnchor.constraint(equalTo: ratingsContainerView.trailingAnchor),
            
            spacer1.heightAnchor.constraint(equalToConstant: 16),
            spacer2.heightAnchor.constraint(equalToConstant: 16),
            
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func updateInfo() {
        titleLabel.text = item.title
        genreLabel.text = item.genre
        awardsLabel.text = item.awards
        ratingsLabel.text = "\(item.imdbRating)/10"
        
        if let image = LocalStorage.shared.retrieve(item.id) {
            imageView.image = image
        } else {
            setImageUnavailable()
        }
        
        updateWatchedButtonIcon(inverted: true)
    }
    
    private func setImageUnavailable() {
        imageView.contentMode = .center
        imageView.tintColor = .colorAsset(.dynamicLabel)
        imageView.image = UIImage.iconAsset(.imageUnavailable)
    }
    
    @objc private func seenButtonTapped() {
        updateWatchedButtonIcon()
        delegate?.didTapSeen(item)
    }
    
    private func updateWatchedButtonIcon(inverted: Bool = false) {
        let markAsWatched = inverted ? item.watched : !item.watched
        
        if markAsWatched {
            seenButton.tintColor = UIColor.systemOrange
        } else {
            seenButton.tintColor = .colorAsset(.dynamicLabelSecondary)
        }
    }
    
    @objc private func favoriteButtonTapped() {
        if favoriteButton.tintColor == UIColor.systemOrange {
            favoriteButton.tintColor = .colorAsset(.dynamicLabelSecondary)
        } else {
            favoriteButton.tintColor = UIColor.systemOrange
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
