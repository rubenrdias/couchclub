//
//  SelectableLabel.swift
//  CouchClub
//
//  Created by Ruben Dias on 20/10/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class SelectableLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        configure()
    }
    
    private func configure() {
        isUserInteractionEnabled = true
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(showMenu))
        addGestureRecognizer(longPressGesture)
    }
    
    @objc private func showMenu() {
        becomeFirstResponder()
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            menu.setTargetRect(bounds, in: self)
            menu.setMenuVisible(true, animated: true)
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(UIResponderStandardEditActions.copy(_:))
    }
    
    override func copy(_ sender: Any?) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = text
        let menu = UIMenuController.shared
        menu.setMenuVisible(false, animated: true)
    }
    
}
