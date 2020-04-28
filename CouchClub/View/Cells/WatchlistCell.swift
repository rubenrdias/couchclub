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
    
    var image: UIImage? {
        didSet { updateImage() }
    }
    var title: String = "" {
        didSet { updateTitle() }
    }
    var subtitle: String = "" {
        didSet { updateSubtitle() }
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
            UIColor.black.withAlphaComponent(0.8)
        ], locations: [0, 0.5, 1], inFrame: contentView.bounds)
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
        let lbl = UILabel.accessibleLabel(.title2, .bold, UIColor.white)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let lbl = UILabel.accessibleLabel(.footnote, .regular, UIColor.colorAsset(.staticGray2))
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
    
    private func updateImage() {
        self.imageView.image = image
    }
    
    private func updateTitle() {
        self.titleLabel.text = title
    }
    
    private func updateSubtitle() {
        self.subtitleLabel.text = subtitle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
