//
//  TitleTextView.swift
//  CouchClub
//
//  Created by Ruben Dias on 04/06/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

protocol TitleDelegate: AnyObject {
    func shouldValidateInputs()
}

class TitleTextView: UITextView {
    
    weak var titleDelegate: TitleDelegate?
    
    var placeholderText: String = "" {
        didSet { showPlaceholderText() }
    }
    
    private let titleRegex = NSRegularExpression(".*")
    private let maxCharacterCount = 60
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        delegate = self
        setupToolbar()
    }
    
    private func setupToolbar() {
        let toolbar = UIToolbar(frame: .init(x: 0, y: 0, width: bounds.width, height: 44))
        toolbar.tintColor = UIColor.systemOrange
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(finishEditing))
        
        toolbar.setItems([spacer, doneButton], animated: false)
        
        inputAccessoryView = toolbar
    }
    
    @objc private func finishEditing() {
        resignFirstResponder()
        titleDelegate?.shouldValidateInputs()
    }
    
    func reset(hardReset: Bool = true) {
        showPlaceholderText()
        textViewDidEndEditing(self)
    }
    
    func showPlaceholderText() {
        text = placeholderText
        font = .translatedFont(for: .body, .regular)
        textColor = .colorAsset(.dynamicLabelSecondary)
    }
    
    func hidePlaceholderText() {
        text = nil
        font = .translatedFont(for: .title2, .semibold)
        textColor = .colorAsset(.dynamicLabel)
    }
}

extension TitleTextView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            hidePlaceholderText()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            showPlaceholderText()
        }
        finishEditing()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        titleDelegate?.shouldValidateInputs()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            finishEditing()
            return false
        } else if titleRegex.matches(text) {
            return textView.text.count + (text.count - range.length) <= maxCharacterCount
        } else {
            return false
        }
    }
}
