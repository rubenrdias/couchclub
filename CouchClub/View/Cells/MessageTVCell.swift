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
    
    private enum Position {
        case left
        case right
    }
    
    // MARK: IBOutlets
    @IBOutlet weak var containerBackgroundView: RoundedView!
    @IBOutlet weak var containerView: UIStackView!
    @IBOutlet var senderLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK: Constraints
    @IBOutlet var containerViewConstraintLeading: NSLayoutConstraint!
    @IBOutlet var containerViewConstraintTrailing: NSLayoutConstraint!
    @IBOutlet weak var containerViewConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var containerViewConstraintBottom: NSLayoutConstraint!
    
    private var message: Message!
    private var hideSender = false
    private var reduceTopPadding = false
    private var reduceBottomPadding = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configureDetails(message: Message, hideSender: Bool) {
        self.message = message
        self.hideSender = hideSender
        
        setupText()
        setupUI()
    }
    
    func configurePadding(reduceTopPadding: Bool, reduceBottomPadding: Bool) {
        self.reduceTopPadding = reduceTopPadding
        self.reduceBottomPadding = reduceBottomPadding
        
        setupPadding()
    }
    
    private func setupText() {
        senderLabel.text = message.sender.username
        messageLabel.text = message.text
    }
    
    private func setupUI() {
        setSenderVisibility(visible: !hideSender)
        
        if message.sentBySelf {
            containerBackgroundView.backgroundColor = UIColor.colorAsset(.dynamicChatBubble)
            adjustPosition(.right)
        } else {
            containerBackgroundView.backgroundColor = .colorAsset(.dynamicBackgroundHighlight)
            adjustPosition(.left)
        }
    }
    
    private func setupPadding() {
        containerViewConstraintTop.constant = reduceTopPadding ? 12 : 16
        containerViewConstraintBottom.constant = reduceBottomPadding ? 8 : 16
    }
    
    private func setSenderVisibility(visible: Bool) {
        if visible, !containerView.arrangedSubviews.contains(senderLabel) {
            containerView.insertArrangedSubview(senderLabel, at: 0)
        } else if !visible, containerView.arrangedSubviews.contains(senderLabel) {
            senderLabel.removeFromSuperview()
        }
    }
    
    private func adjustPosition(_ position: Position) {
        NSLayoutConstraint.deactivate([containerViewConstraintLeading, containerViewConstraintTrailing])
        
        switch position {
        case .left:
            NSLayoutConstraint.activate([containerViewConstraintLeading])
        case .right:
            NSLayoutConstraint.activate([containerViewConstraintTrailing])
        }
    }
    
}
