//
//  Alerts.swift
//  CouchClub
//
//  Created by Ruben Dias on 30/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class Alerts {
    
    static func simpleAlert(title: String?, message: String?, action: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.view.tintColor = .colorAsset(.dynamicLabel)
        
        ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: action))
        
        return ac
    }
    
    static func deletionAlert(title: String?, message: String?, action: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.view.tintColor = .colorAsset(.dynamicLabel)
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        ac.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: action))
        
        return ac
    }
    
}
