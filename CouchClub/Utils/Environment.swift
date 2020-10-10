//
//  Environment.swift
//  CouchClub
//
//  Created by Ruben Dias on 06/10/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import Foundation

public enum Environment {
    
    // MARK: Keys
    private enum ConfigVariables {
        static let omdbBaseURL = "OMDB_BASE_URL"
        static let omdbApiKey = "OMDB_API_KEY"
    }
    
    // MARK: Plist
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()
    
    // MARK: Plist values
    
    static let OMDB_BASE_URL: URL = {
        guard let rootURLstring = Environment.infoDictionary[ConfigVariables.omdbBaseURL] as? String else {
            fatalError("OMDB BASE URL not set in plist for this environment")
        }
        guard let url = URL(string: "http://\(rootURLstring)") else {
            fatalError("OMDB BASE URL is invalid")
        }
        return url
    }()
    
    static let OMDB_API_KEY: String = {
        guard let apiKey = Environment.infoDictionary[ConfigVariables.omdbApiKey] as? String else {
            fatalError("OMDB_API_KEY not set in plist for this environment")
        }
        return apiKey
    }()
    
}
