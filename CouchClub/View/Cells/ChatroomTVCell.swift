//
//  ChatroomTVCell.swift
//  CouchClub
//
//  Created by Ruben Dias on 10/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class ChatroomTVCell: UITableViewCell {
    
    static let reuseIdentifier = "ChatroomTVCell"
    
    var chatroom: Chatroom! {
        didSet { updateInfo() }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        setupImage()
        setupText()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        objectImageView.image = nil
        objectImageView.contentMode = .scaleAspectFill
        titleLabel.text = nil
        dateLabel.text = nil
        messageLabel.text = nil
    }
    
    private lazy var objectImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .colorAsset(.dynamicLabel)
        iv.backgroundColor = .lightGray
        iv.layer.cornerRadius = 4
        iv.clipsToBounds = true
        return iv
    }()
    
    private func setupImage() {
        let width = contentView.bounds.width * 0.15
        
        contentView.addSubview(objectImageView)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: objectImageView, attribute: .height, relatedBy: .equal, toItem: objectImageView, attribute: .width, multiplier: 3/2, constant: 0),
            objectImageView.widthAnchor.constraint(equalToConstant: width),
            objectImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            objectImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            objectImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        ])
    }
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, spacer1, dateLabel, messageLabel, spacer2])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.alignment = .fill
        return sv
    }()
        
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel.standardLabel(.body, .semibold, .colorAsset(.dynamicLabel))
        lbl.numberOfLines = 2
        lbl.adjustsFontSizeToFitWidth = true
        return lbl
    }()
    
    private lazy var dateLabel: UILabel = {
        let lbl = UILabel.standardLabel(.caption1, .regular, .colorAsset(.dynamicLabelSecondary))
        lbl.numberOfLines = 1
        return lbl
    }()
    
    private lazy var messageLabel: UILabel = {
        let lbl = UILabel.standardLabel(.caption1, .regular, .colorAsset(.dynamicLabelSecondary))
        lbl.numberOfLines = 1
        return lbl
    }()
    
    private lazy var spacer1 = UIView.spacerView()
    private lazy var spacer2 = UIView.spacerView()
    
    private func setupText() {
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            spacer1.heightAnchor.constraint(equalToConstant: 4),
            spacer2.heightAnchor.constraint(equalToConstant: 2),
            
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: objectImageView.trailingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func updateInfo() {
        titleLabel.text = chatroom.title
        
		if let lastMessage = chatroom.lastMessage {
			dateLabel.text = messageSectionFormatter.string(from: lastMessage.date)
			
			if lastMessage.sender.id == FirebaseService.currentUserID! {
				messageLabel.text = lastMessage.text
			} else {
				messageLabel.text = "\(lastMessage.sender.username): \(lastMessage.text)"
			}
		}
        
        getThumbnailImage { thumbnail in
            DispatchQueue.main.async { [weak self] in
                if let thumbnail = thumbnail {
                    self?.objectImageView.contentMode = .scaleAspectFill
                    self?.objectImageView.image = thumbnail
                } else {
                    self?.setImageUnavailable()
                }
            }
        }
    }
    
    private func getThumbnailImage(completion: @escaping (_ image: UIImage?)->()) {
        switch chatroom.type {
        case ChatroomType.watchlist.rawValue:
            guard let watchlistID = UUID(uuidString: chatroom.subjectID), let watchlist = LocalDatabase.shared.fetchWatchlist(watchlistID) else {
                completion(nil)
                return
            }
            
            watchlist.getThumbnail { thumbnail in
                completion(thumbnail)
            }
        default:
            guard let item = LocalDatabase.shared.fetchItem(chatroom.subjectID) else { fatalError("Fetching thumbnail for chatroom \(chatroom.id.uuidString) but subject does not exist in database.") }
            
            DataCoordinator.shared.getImage(forItem: item) { (thumbnail) in
                completion(thumbnail)
            }
        }
    }
    
    private func setImageUnavailable() {
        objectImageView.contentMode = .center
        objectImageView.image = UIImage.iconAsset(.imageUnavailable)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
