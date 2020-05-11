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
        
        if let messages = chatroom.messages?.allObjects as? [Message] {
            let sortedMessages = messages.sorted { $0.date > $1.date }
            if let lastMessage = sortedMessages.first {
                dateLabel.text = messageSectionFormatter.string(from: lastMessage.date)
                if lastMessage.sender == "Me" {
                    messageLabel.text = lastMessage.text
                } else {
                    messageLabel.text = "\(lastMessage.sender): \(lastMessage.text)"
                }
            }
        }
        
        if let image = getThumbnailImage() {
            objectImageView.image = image
        } else {
            setImageUnavailable()
        }
        
    }
    
    private func getThumbnailImage() -> UIImage? {
        switch chatroom.type {
        case ChatroomType.watchlist.rawValue :
            guard let watchlistID = UUID(uuidString: chatroom.subjectID) else { return nil }
            guard let watchlist = LocalDatabase.shared.fetchWatchlist(watchlistID) else { return nil }
            return watchlist.getThumbnail()
        default:
            return LocalStorage.shared.retrieve(chatroom.subjectID)
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
