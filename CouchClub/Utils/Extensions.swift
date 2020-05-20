//
//  Extensions.swift
//  CouchClub
//
//  Created by Ruben Dias on 30/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import Foundation
import UIKit
import Firebase

// MARK: - UIView

extension UIView {
    
    static func spacerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }
    
    func setGradientBackground(colors: [UIColor], locations: [NSNumber], inFrame: CGRect? = nil) {
        let cgColors = colors.map { $0.cgColor }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = inFrame ?? bounds
        gradientLayer.colors = cgColors
        gradientLayer.locations = locations
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        
        if let sublayers = layer.sublayers, let currentGradientLayer = sublayers[0] as? CAGradientLayer {
            layer.replaceSublayer(currentGradientLayer, with: gradientLayer)
        }
        else {
            layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
}

// MARK: - UIButton

extension UIButton {
    
    func makeCTA(style: ButtonStyle = .primary) {
        backgroundColor = style == .primary ? UIColor.systemOrange : UIColor.init(white: 0.4, alpha: 1)
        setTitleColor(UIColor.white, for: .normal)
        titleLabel?.font = .translatedFont(for: .headline, .semibold)
    }
    
}

// MARK: - UILabel

extension UILabel {
    
    static func accessibleLabel(_ style: UIFont.TextStyle,_ weight: UIFont.Weight, _ color: UIColor? = nil) -> UILabel {
        let lbl = UILabel()
        lbl.adjustsFontForContentSizeCategory = true
        lbl.font = .translatedFont(for: style, weight)
        
        if let color = color {
            lbl.textColor = color
        }
        
        return lbl
    }
    
    static func standardLabel(_ style: UIFont.TextStyle,_ weight: UIFont.Weight, _ color: UIColor? = nil) -> UILabel {
        let lbl = UILabel()
        let size = UIFont.translatedFontSize(for: style)
        lbl.font = .systemFont(ofSize: size, weight: weight)
        
        if let color = color {
            lbl.textColor = color
        }
        
        return lbl
    }
    
}

// MARK: - UIImage

extension UIImage {
    
    enum Icon: String {
        case chatrooms
        case checkmark
        case heart
        case imageUnavailable
        case imdb
        case list
        case send
        case settings
        case thumbnails
        case watchlists
    }
    
    static func iconAsset(_ name: Icon) -> UIImage {
        return UIImage(named: name.rawValue)!
    }
    
}

// MARK: - UIFont

extension UIFont {
    
    static func translatedFont(for style: UIFont.TextStyle, _ weight: UIFont.Weight) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: style)
        let customFont = UIFont.systemFont(ofSize: translatedFontSize(for: style), weight: weight)
        return metrics.scaledFont(for: customFont)
    }
    
    static func translatedFontSize(for style: UIFont.TextStyle) -> CGFloat {
        switch style {
        case .body:
            return 17
        case .callout:
            return 16
        case .caption1:
            return 12
        case .caption2:
            return 11
        case .footnote:
            return 13
        case .headline:
            return 17
        case .largeTitle:
            return 34
        case .subheadline:
            return 15
        case .title1:
            return 28
        case .title2:
            return 22
        case .title3:
            return 20
        default:
            return 0
        }
    }
    
}

// MARK: - UIColor

extension UIColor {
    
    enum AssetColorName: String {
        case dynamicBackground = "Dynamic.Background"
        case dynamicBackgroundHighlight = "Dynamic.BackgroundHighlight"
        case dynamicChatBubble = "Dynamic.ChatBubble"
        case dynamicLabel = "Dynamic.Label"
        case dynamicLabelSecondary = "Dynamic.LabelSecondary"
        case dynamicSecondary = "Dynamic.Secondary"
        case dynamicTertiary = "Dynamic.LabelTertiary"
        case dynamicSeparator = "Dynamic.Separator"
        case staticGray2 = "Static.Gray2"
    }
    
    static func colorAsset(_ name: AssetColorName) -> UIColor {
        return UIColor(named: name.rawValue) ?? UIColor.black
    }
    
}

// MARK: - Notification.Name

extension Notification.Name {
    
    // watchlists
    static let watchlistsDidChange = Notification.Name("watchlistsDidChange")
    static let watchlistDidChange = Notification.Name("watchlistDidChange")
    
    // chatrooms
    static let chatroomsDidChange = Notification.Name("chatroomsDidChange")
    static let chatroomDidChange = Notification.Name("chatroomDidChange")
    
}

// MARK: - NSRegularExpression

extension NSRegularExpression {
    
    convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }
    
    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }
    
}
