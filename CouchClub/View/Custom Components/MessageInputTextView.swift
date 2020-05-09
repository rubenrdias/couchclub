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
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        delegate = self
        
        translatesAutoresizingMaskIntoConstraints = false
        isScrollEnabled = false
        
        textContainerInset = .init(top: 8, left: 8, bottom: 8, right: 8)
        
        backgroundColor = .colorAsset(.dynamicBackgroundHighlight)
        layer.cornerRadius = 14
        clipsToBounds = true
        
        font = UIFont.systemFont(ofSize: 16)
    }
    
    func reset() {
        text = nil
        textViewDidEndEditing(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CommentInputTextView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if text == placeholderText {
            text = nil
            textColor = .colorAsset(.dynamicLabel)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if text == placeholderText || text.isEmpty {
            text = placeholderText
            textColor = .colorAsset(.dynamicLabelSecondary)
        }
    }
    
}
