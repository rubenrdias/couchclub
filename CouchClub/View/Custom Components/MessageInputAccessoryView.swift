//
//  MessageInputAccessoryView.swift
//  CouchClub
//
//  Created by Ruben Dias on 08/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class MessageInputAccessoryView: UIView {
    
    weak var delegate: MessageDelegate?

    private let messageTextView: CommentInputTextView = {
        let tv = CommentInputTextView()
        tv.placeholderText = "Enter message..."
        tv.showPlaceholderText()
        return tv
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.iconAsset(.send), for: .normal)
        button.tintColor = UIColor.systemOrange
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        autoresizingMask = .flexibleHeight
        backgroundColor = .white
        
        let lineSeparatorView = UIView()
        lineSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        lineSeparatorView.backgroundColor = .colorAsset(.dynamicSeparator)
        
        addSubview(sendButton)
        addSubview(messageTextView)
        addSubview(lineSeparatorView)
        NSLayoutConstraint.activate([
            sendButton.widthAnchor.constraint(equalToConstant: 32),
            sendButton.heightAnchor.constraint(equalToConstant: 32),
            sendButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            messageTextView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            messageTextView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8),
            messageTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageTextView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            
            lineSeparatorView.heightAnchor.constraint(equalToConstant: 0.5),
            lineSeparatorView.topAnchor.constraint(equalTo: topAnchor),
            lineSeparatorView.leftAnchor.constraint(equalTo: leftAnchor),
            lineSeparatorView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    func dismissKeyboard() {
        messageTextView.resignFirstResponder()
    }
    
    @objc func handleSend() {
        guard let messageText = messageTextView.text else { return }
        delegate?.didSendMessage(messageText)
        messageTextView.reset()
        messageTextView.resignFirstResponder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
