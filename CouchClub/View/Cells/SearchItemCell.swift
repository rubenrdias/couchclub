//
//  SearchItemCell.swift
//  CouchClub
//
//  Created by Ruben Dias on 26/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class SearchItemCell: UICollectionViewCell {
    
    static let reuseIdentifier = "SearchItemCell"
    
    var searchItem: SearchItem! {
        didSet { updateImage() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 8
        contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
        
        setupImage()
    }
    
    override func prepareForReuse() {
        imageView.image = nil
    }
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
        return iv
    }()
    
    private func setupImage() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }
    
    private func updateImage() {
        // TODO: fetch poster image
//        self.imageView.image = searchItem.poster
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
