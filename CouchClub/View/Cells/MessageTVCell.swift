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
    
    var message: Message! {
        didSet {
            messageLabel.attributedText = attributtedMessageText()
            
            let sentByMe = message.sender == "Me"
            if sentByMe {
                bubbleBackgroundView.backgroundColor = .colorAsset(.dynamicBackgroundHighlight)
            } else {
                bubbleBackgroundView.backgroundColor = UIColor.colorAsset(.dynamicSecondary).withAlphaComponent(0.5)
            }
            
            leadingConstraint.isActive = !sentByMe
            trailingConstraint.isActive = sentByMe
        }
    }
    
    var shouldReduceTopMargin: Bool = false {
        didSet {
            topConstraintSpaced.isActive = !shouldReduceTopMargin
            topConstraintTight.isActive = shouldReduceTopMargin
        }
    }
    var shouldReduceBottomMargin: Bool = false {
        didSet {
            bottomConstraintSpaced.isActive = !shouldReduceBottomMargin
            bottomConstraintTight.isActive = shouldReduceBottomMargin
        }
    }
    
    var topConstraintSpaced: NSLayoutConstraint!
    var topConstraintTight: NSLayoutConstraint!
    var bottomConstraintSpaced: NSLayoutConstraint!
    var bottomConstraintTight: NSLayoutConstraint!
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
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        let maxWidth = contentView.bounds.width * 0.8
        
        contentView.addSubview(bubbleBackgroundView)
        contentView.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth),
            
            bubbleBackgroundView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -12),
            bubbleBackgroundView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 12),
            bubbleBackgroundView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -12),
            bubbleBackgroundView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 12)
        ])
        
        topConstraintSpaced = messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20)
        topConstraintTight = messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12)
        bottomConstraintSpaced = messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        bottomConstraintTight = messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        leadingConstraint = messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28)
        trailingConstraint = messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28)
    }
    
    private func attributtedMessageText() -> NSAttributedString {
        let messageString = NSMutableAttributedString()
        
        if message.sender != "Me" {
            let senderAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.translatedFont(for: .footnote, .bold)
            ]
            messageString.append(NSAttributedString(string: "\(message.sender)\n", attributes: senderAttributes))
        }
        
        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.translatedFont(for: .subheadline, .regular)
        ]
        
        messageString.append(NSAttributedString(string: "\(message.text)", attributes: bodyAttributes))
        
        return messageString
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
