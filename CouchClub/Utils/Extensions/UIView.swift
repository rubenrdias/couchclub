//
//  UIView.swift
//  CouchClub
//
//  Created by Ruben Dias on 25/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

extension UIView {
    
    func setGradientBackground(colors: [UIColor], locations: [NSNumber]) {
        let cgColors = colors.map { $0.cgColor }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = cgColors
        gradientLayer.locations = locations
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
}
