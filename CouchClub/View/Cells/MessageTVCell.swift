//
//  MessageTVCell.swift
//  CouchClub
//
//  Created by Ruben Dias on 08/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class MessageTVCell: UITableViewCell {
    
    static let reuseIdentifier = "MessageTVCell"
    
    var message: String! {
        didSet {
            messageLabel.text = message
        }
    }
    var sender: Bool! {
        didSet {
            bubbleBackgroundView.backgroundColor = .colorAsset(sender ? .dynamicBackgroundHighlight : .dynamicSecondary)
            leadingConstraint.isActive = !sender
            trailingConstraint.isActive = sender
        }
    }
    
    var leadingConstraint: NSLayoutConstraint!
    var trailingConstraint: NSLayoutConstraint!
    
    private lazy var bubbleBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4
        return view
    }()

    private lazy var messageLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 0
        return lbl
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let maxWidth = contentView.bounds.width * 0.8
        
        contentView.addSubview(bubbleBackgroundView)
        contentView.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth),
            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            bubbleBackgroundView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -16),
            bubbleBackgroundView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
            bubbleBackgroundView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -16),
            bubbleBackgroundView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 16)
        ])
        
        leadingConstraint = messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32)
        trailingConstraint = messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
