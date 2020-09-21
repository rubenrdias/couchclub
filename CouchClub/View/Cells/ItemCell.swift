//
//  ItemCell.swift
//  CouchClub
//
//  Created by Ruben Dias on 02/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class ItemCell: UICollectionViewCell {
    
    weak var delegate: ItemOperationDelegate?
    
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
        setupSeenButton()
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
        imageView.contentMode = .scaleAspectFill
        titleLabel.text = nil
        subtitleLabel.text = nil
    }
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
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
        sv.spacing = 4
        return sv
    }()
    
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel.standardLabel(.subheadline, .bold, UIColor.white)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let lbl = UILabel.standardLabel(.caption1, .regular, .colorAsset(.staticGray2))
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
    
    private lazy var buttonBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(seenButtonTapped))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }()
    
    @objc private func tapSeenButton() {
        seenButton.sendActions(for: .touchUpInside)
    }
    
    private lazy var seenButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage.iconAsset(.checkmark), for: .normal)
        btn.addTarget(self, action: #selector(seenButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    @objc private func seenButtonTapped() {
        updateWatchedButtonIcon()
        delegate?.didTapSeen(item)
    }
    
    func updateWatchedButtonIcon(inverted: Bool = false) {
        let markAsWatched = inverted ? item.watched : !item.watched
        
        if markAsWatched {
            buttonBackground.backgroundColor = UIColor.systemOrange
            seenButton.tintColor = UIColor.white
        } else {
            buttonBackground.backgroundColor = UIColor.init(white: 0.2, alpha: 0.8)
            seenButton.tintColor = UIColor.init(white: 1, alpha: 0.4)
        }
    }
    
    private func setupSeenButton() {
        imageView.addSubview(buttonBackground)
        imageView.addSubview(seenButton)
        NSLayoutConstraint.activate([
            buttonBackground.heightAnchor.constraint(equalToConstant: 120),
            buttonBackground.widthAnchor.constraint(equalToConstant: 50),
            buttonBackground.centerYAnchor.constraint(equalTo: imageView.topAnchor),
            buttonBackground.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            
            seenButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 6),
            seenButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -6)
        ])
        
        buttonBackground.transform = buttonBackground.transform.rotated(by: -.pi/4)
    }
    
    private func updateInfo() {
        updateWatchedButtonIcon(inverted: true)
        
        titleLabel.text = item.title
        subtitleLabel.text = "\(item.year)  \(item.runtime)"
        
        DataCoordinator.shared.getImage(forItem: item) { image in
            DispatchQueue.main.async { [weak self] in
                if let image = image {
                    self?.imageView.image = image
                } else {
                    self?.setImageUnavailable()
                }
            }
        }
    }
    
    func setImageUnavailable() {
        contentView.backgroundColor = .colorAsset(.dynamicBackgroundHighlight)
        imageView.contentMode = .center
        imageView.tintColor = .colorAsset(.dynamicLabel)
        imageView.image = UIImage.iconAsset(.imageUnavailable)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
