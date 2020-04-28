//
//  UIColor.swift
//  CouchClub
//
//  Created by Ruben Dias on 26/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

extension UIColor {
    
    enum AssetColorName: String {
        case dynamicBackground = "Dynamic.Background"
        case dynamicLabel = "Dynamic.Label"
        case dynamicLabelSecondary = "Dynamic.LabelSecondary"
        case dynamicMutedHighlight = "Dynamic.MutedHighlight"
        case dynamicSeparator = "Dynamic.Separator"
        case staticGray2 = "Static.Gray2"
    }
    
    static func colorAsset(_ name: AssetColorName) -> UIColor {
        return UIColor(named: name.rawValue) ?? UIColor.black
    }
    
}
