//
//  UIImage.swift
//  CouchClub
//
//  Created by Ruben Dias on 27/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

extension UIImage {
    
    enum Icon: String {
        case chatrooms
        case imageUnavailable
        case list
        case settings
        case thumbnails
        case watchlists
    }
    
    static func iconAsset(_ name: Icon) -> UIImage {
        return UIImage(named: name.rawValue)!
    }
    
}
