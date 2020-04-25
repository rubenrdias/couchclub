//
//  WatchlistCell.swift
//  CouchClub
//
//  Created by Ruben Dias on 25/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class WatchlistCell: UICollectionViewCell {
    
    static let reuseIdentifier = "watchlistCell"
    
    let imageName = "avengers_1"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.clipsToBounds = true
        
        setupImage()
        setupTextBackground()
    }
    
    override func prepareForReuse() {
        imageView.removeFromSuperview()
    }
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
        return iv
    }()
    
    private func setupImage() {
        let image = UIImage(named: imageName)
        imageView.image = image
        
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16)
        ])
    }
    
    private let textContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private func setupTextBackground() {
        imageView.addSubview(textContainer)
        NSLayoutConstraint.activate([
            textContainer.heightAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 0.5),
            textContainer.leftAnchor.constraint(equalTo: imageView.leftAnchor),
            textContainer.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            textContainer.rightAnchor.constraint(equalTo: imageView.rightAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
