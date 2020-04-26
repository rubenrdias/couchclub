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
        
        setupImage()
        setupText()
    }
    
    override func prepareForReuse() {
        imageView.image = nil
        titleTextLabel.text = nil
        subtitleTextLabel.text = nil
    }
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
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
    
    private lazy var textContainer: UIView = {
        let width = contentView.bounds.width
        let height = contentView.bounds.height
        
        let view = UIView(frame: .init(x: 0, y: 0, width: width, height: height))
        view.setGradientBackground(colors: [
            UIColor.clear,
            UIColor.black.withAlphaComponent(0.2),
            UIColor.black.withAlphaComponent(0.7)
        ], locations: [0, 0.5, 1])
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleTextLabel, subtitleTextLabel])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        return sv
    }()
    
    private lazy var titleTextLabel: UILabel = {
        let lbl = UILabel.standardLabel(.title2, .bold, UIColor.white)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private lazy var subtitleTextLabel: UILabel = {
        let lbl = UILabel.standardLabel(.footnote, .regular, UIColor.colorAsset(.staticGray2))
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private func setupText() {
        textContainer.addSubview(stackView)
        imageView.addSubview(textContainer)
        
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: textContainer.bottomAnchor, constant: -16),
            stackView.leftAnchor.constraint(equalTo: textContainer.leftAnchor, constant: 16),
            stackView.rightAnchor.constraint(equalTo: textContainer.rightAnchor, constant: -16)
        ])
    }
    
    private func updateImage() {
        self.imageView.image = image
    }
    
    private func updateTitle() {
        self.titleTextLabel.text = title
    }
    
    private func updateSubtitle() {
        self.subtitleTextLabel.text = subtitle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
