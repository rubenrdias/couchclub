//
//  ItemDetailHeaderTVCell.swift
//  CouchClub
//
//  Created by Ruben Dias on 27/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class ItemDetailHeaderTVCell: UITableViewHeaderFooterView {
    
    static let reuseIdentifier = "ItemDetailHeaderTVCell"
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor.colorAsset(.dynamicBackground)
        
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
        let lbl = UILabel.standardLabel(.title2, .bold, UIColor.colorAsset(.dynamicLabel))
        lbl.numberOfLines = 2
        lbl.adjustsFontSizeToFitWidth = true
        return lbl
    }()
    
    private lazy var genreLabel: UILabel = {
        let lbl = UILabel.standardLabel(.footnote, .regular, UIColor.colorAsset(.dynamicLabelSecondary))
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private lazy var awardsLabel: UILabel = {
        let lbl = UILabel.standardLabel(.footnote, .regular, UIColor.colorAsset(.dynamicLabelSecondary))
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
        let lbl = UILabel.standardLabel(.footnote, .regular, UIColor.colorAsset(.dynamicLabelSecondary))
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private lazy var seenButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(seenButtonTapped), for: .touchUpInside)
        btn.imageEdgeInsets = .init(top: 2, left: 2, bottom: 2, right: 2)
        btn.setImage(UIImage.iconAsset(.checkmark), for: .normal)
        btn.tintColor = UIColor.colorAsset(.dynamicLabelSecondary)
        return btn
    }()
    
    private lazy var favoriteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        btn.imageEdgeInsets = .init(top: 2, left: 2, bottom: 2, right: 2)
        btn.setImage(UIImage.iconAsset(.heart), for: .normal)
        btn.tintColor = UIColor.colorAsset(.dynamicLabelSecondary)
        return btn
    }()
    
    private func setupText() {
        ratingsContainerView.addSubview(imdbIconView)
        ratingsContainerView.addSubview(ratingsLabel)
        ratingsContainerView.addSubview(seenButton)
        ratingsContainerView.addSubview(favoriteButton)
        
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            ratingsContainerView.heightAnchor.constraint(equalToConstant: 30),
            
            imdbIconView.heightAnchor.constraint(equalToConstant: 30),
            imdbIconView.leadingAnchor.constraint(equalTo: ratingsContainerView.leadingAnchor),
            imdbIconView.centerYAnchor.constraint(equalTo: ratingsContainerView.centerYAnchor),
            
            ratingsLabel.leadingAnchor.constraint(equalTo: imdbIconView.trailingAnchor, constant: 8),
            ratingsLabel.centerYAnchor.constraint(equalTo: ratingsContainerView.centerYAnchor),
            
            NSLayoutConstraint(item: seenButton, attribute: .height, relatedBy: .equal, toItem: seenButton, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: favoriteButton, attribute: .height, relatedBy: .equal, toItem: favoriteButton, attribute: .width, multiplier: 1, constant: 0),

            seenButton.heightAnchor.constraint(equalTo: ratingsContainerView.heightAnchor),
            seenButton.centerYAnchor.constraint(equalTo: ratingsContainerView.centerYAnchor),
            seenButton.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor),
            favoriteButton.heightAnchor.constraint(equalTo: ratingsContainerView.heightAnchor),
            favoriteButton.centerYAnchor.constraint(equalTo: ratingsContainerView.centerYAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: ratingsContainerView.trailingAnchor),
            
            spacer1.heightAnchor.constraint(equalToConstant: 16),
            spacer2.heightAnchor.constraint(equalToConstant: 16),
            
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func updateText(_ movie: Movie) {
        titleLabel.text = movie.title
        genreLabel.text = movie.genre
        awardsLabel.text = movie.awards
        ratingsLabel.text = "\(movie.imdbRating)/10"
        imageView.image = UIImage(named: "avengers_1")
    }
    
    @objc private func seenButtonTapped() {
        if seenButton.tintColor == UIColor.systemOrange {
            seenButton.tintColor = UIColor.colorAsset(.dynamicLabelSecondary)
        } else {
            seenButton.tintColor = UIColor.systemOrange
        }
    }
    
    @objc private func favoriteButtonTapped() {
        if favoriteButton.tintColor == UIColor.systemOrange {
            favoriteButton.tintColor = UIColor.colorAsset(.dynamicLabelSecondary)
        } else {
            favoriteButton.tintColor = UIColor.systemOrange
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
