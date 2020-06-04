//
//  MessageInputTextView.swift
//  CouchClub
//
//  Created by Ruben Dias on 08/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class CommentInputTextView: UITextView {
    
    var placeholderText: String = "" {
        didSet { textColor = .colorAsset(.dynamicLabelSecondary) }
    }
    
    var heightConstraint: NSLayoutConstraint?
    var singleLineHeightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        delegate = self
        
        translatesAutoresizingMaskIntoConstraints = false
        isScrollEnabled = false
        
        contentInset = .init(top: 8, left: 0, bottom: 8, right: 0)
        textContainerInset = .init(top: 8, left: 8, bottom: 8, right: 8)
        
        scrollIndicatorInsets = .init(top: 8, left: 0, bottom: 8, right: 0)
        
        backgroundColor = .colorAsset(.dynamicBackground)
        layer.cornerRadius = 14
        clipsToBounds = true
        
        font = UIFont.translatedFont(for: .body, .regular)
    }
    
    func reset(hardReset: Bool = true) {
        if hardReset {
            showPlaceholderText()
            textViewDidEndEditing(self)
        } else {
            text = ""
        }
    }
    
    func showPlaceholderText() {
        text = placeholderText
        textColor = .colorAsset(.dynamicLabelSecondary)
    }
    
    func hidePlaceholderText() {
        text = nil
        textColor = .colorAsset(.dynamicLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CommentInputTextView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if text == placeholderText {
            hidePlaceholderText()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if text == placeholderText || text.isEmpty {
            showPlaceholderText()
        }
    }
    
}
