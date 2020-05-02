//
//  ItemCell.swift
//  CouchClub
//
//  Created by Ruben Dias on 02/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class ItemCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ItemCell"
    
    var item: Item! {
        didSet { updateInfo() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 4
        
        setupImage()
        setupText()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.setGradientBackground(colors: [
            UIColor.clear,
            UIColor.black.withAlphaComponent(0.3),
            UIColor.black.withAlphaComponent(0.9)
        ], locations: [0, 0.4, 1], inFrame: contentView.bounds)
    }
    
    override func prepareForReuse() {
        imageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private func setupImage() {
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        return sv
    }()
    
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel.accessibleLabel(.subheadline, .bold, UIColor.white)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let lbl = UILabel.accessibleLabel(.caption1, .regular, UIColor.colorAsset(.staticGray2))
        return lbl
    }()
    
    private func setupText() {
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
        ])
    }
    
    private func updateInfo() {
        if item.poster != "N/A", let image = LocalStorage.shared.retrieve(item.id) {
            imageView.image = image
        } else {
            setImageUnavailable()
        }
        
        titleLabel.text = item.title
        subtitleLabel.text = "\(item.year)  \(item.runtime)"
    }
    
    func setImageUnavailable() {
        contentView.backgroundColor = UIColor.colorAsset(.dynamicBackgroundHighlight)
        imageView.contentMode = .center
        imageView.tintColor = UIColor.colorAsset(.dynamicLabel)
        imageView.image = UIImage.iconAsset(.imageUnavailable)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
