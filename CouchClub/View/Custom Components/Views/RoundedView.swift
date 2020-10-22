//
//  RoundedView.swift
//  CouchClub
//
//  Created by Ruben Dias on 17/10/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedView: UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat = 4 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
}
