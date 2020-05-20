//
//  Views.swift
//  CouchClub
//
//  Created by Ruben Dias on 20/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class BlurredView: UIView {
    
    private var blurWasAdded = false
    
    override func layoutSubviews() {
        super.layoutSubviews()

        addBlurEffect()
    }

    private func addBlurEffect() {
        if !blurWasAdded {
            let blurEffectView = createBlurEffectView()
            insertSubview(blurEffectView, at: 0)
            
            blurWasAdded = true
        }
    }
    
    private func createBlurEffectView() -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
    
        return blurEffectView
    }
}
