//
//  UserDefaultsManager.swift
//  CouchClub
//
//  Created by Ruben Dias on 03/10/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import Foundation

class UserDefaultsManager {
    
    private enum Keys: String {
        case isFirstLaunch
    }
    
    static let shared = UserDefaultsManager()
    private init() {}
    
    let defaults = UserDefaults.standard
    
    var isFirstLaunch: Bool {
        get { return defaults.value(forKey: Keys.isFirstLaunch.rawValue) as? Bool ?? true }
        set { defaults.setValue(newValue, forKey: Keys.isFirstLaunch.rawValue) }
    }
    
}
