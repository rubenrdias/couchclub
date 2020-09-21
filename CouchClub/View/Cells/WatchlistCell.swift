//
//  WatchlistCell.swift
//  CouchClub
//
//  Created by Ruben Dias on 25/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class WatchlistCell: UICollectionViewCell {
    
    static let reuseIdentifier = "WatchlistCell"
    
    var watchlist: Watchlist! {
        didSet { updateInfo() }
    }
    
    var subtitle: String = "" {
        didSet { updateSubtitle() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .colorAsset(.dynamicBackgroundHighlight)
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 4
        
        setupImage()
        setupText()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.setGradientBackground(colors: [
            UIColor.clear,
            UIColor.init(white: 0, alpha: 0.2),
            UIColor.init(white: 0, alpha: 0.9)
        ], locations: [0, 0.4, 1], inFrame: contentView.bounds)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = .colorAsset(.dynamicLabel)
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
        let lbl = UILabel.accessibleLabel(.title1, .bold, UIColor.white)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let lbl = UILabel.accessibleLabel(.subheadline, .regular, .colorAsset(.staticGray2))
        return lbl
    }()
    
    private func setupText() {
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
    
    private func updateInfo() {
        titleLabel.text = watchlist.title
        
        watchlist.getThumbnail { thumbnail in
            DispatchQueue.main.async { [weak self] in
                if let thumbnail = thumbnail {
                    self?.imageView.contentMode = .scaleAspectFill
                    self?.imageView.image = thumbnail
                } else {
                    self?.setImageUnavailable()
                }
            }
        }
    }
    
    private func updateSubtitle() {
        subtitleLabel.text = subtitle
    }
    
    func setImageUnavailable() {
        imageView.contentMode = .center
        imageView.image = UIImage.iconAsset(.imageUnavailable)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
