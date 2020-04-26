//
//  UILabel.swift
//  CouchClub
//
//  Created by Ruben Dias on 26/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

extension UILabel {
    
    static func standardLabel(_ style: UIFont.TextStyle,_ weight: UIFont.Weight, _ color: UIColor? = nil) -> UILabel {
        let lbl = UILabel()
        lbl.adjustsFontForContentSizeCategory = true
                
        lbl.font = UIFont.translatedFont(for: style, weight)
        
        if let color = color {
            lbl.textColor = color
        }
        
        return lbl
    }
    
}
