//
//  CTAButton.swift
//  CouchClub
//
//  Created by Ruben Dias on 13/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 4
        clipsToBounds = true
    }
    
}
