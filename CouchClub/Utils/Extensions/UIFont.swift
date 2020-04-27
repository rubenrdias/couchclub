//
//  UIFont.swift
//  CouchClub
//
//  Created by Ruben Dias on 26/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

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
