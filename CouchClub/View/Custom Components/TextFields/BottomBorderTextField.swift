//
//  BottomBorderTextField.swift
//  CouchClub
//
//  Created by Ruben Dias on 17/10/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class BottomBorderTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addBottomBorder()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        addBottomBorder()
    }
    
    private func addBottomBorder() {
        let border = UIView()
        border.backgroundColor = .colorAsset(.dynamicSeparator)
        border.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(border)
        NSLayoutConstraint.activate([
            border.heightAnchor.constraint(equalToConstant: 0.5),
            border.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -0.5),
            border.leftAnchor.constraint(equalTo: leftAnchor),
            border.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
}
