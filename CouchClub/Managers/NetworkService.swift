//
//  NetworkService.swift
//  CouchClub
//
//  Created by Ruben Dias on 26/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import Foundation

fileprivate struct SearchResult: Decodable {
    
    let results: [SearchItem]
    let totalResults: String
    
    enum CodingKeys: String, CodingKey {
        case results = "Search"
        case totalResults = "totalResults"
    }
    
}

struct SearchItem: Decodable {
    
    let uuid: String
    let title: String
    let poster: String
    
    enum CodingKeys: String, CodingKey {
        case uuid = "imdbID"
        case title = "Title"
        case poster = "Poster"
    }
}

class NetworkService {
    
    enum ResultType: String {
        case movie
        case show
    }
    
    static var shared = NetworkService()
    
    let baseURL = "http://www.omdbapi.com/"
    let apiKey = "d4d6a41c"
    
    func searchResults(resultType: ResultType, searchText: String, completion: @escaping (_ results: [Any]?, _ totalResults: Int)->()) {
        var url = URLComponents(string: baseURL)!
        
        let params = [
            "apikey": apiKey,
            "s": searchText,
            "type": resultType.rawValue
        ]
        
        url.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        URLSession.shared.dataTask(with: url.url!) { (data, response, error) in
            guard let data = data else {
                if let error = error {
                    print("Failed to fetch search results: \(error.localizedDescription)")
                }
                completion(nil, 0)
                return
            }
            
            let searchResult = try? JSONDecoder().decode(SearchResult.self, from: data)
            if let results = searchResult?.results, let totalResults = Int(searchResult?.totalResults ?? "") {
                print("\(results.count) \(resultType == .movie ? "movie" : "show")(s) found")
                completion(results, totalResults)
            } else {
                print("No movies found")
                completion(nil, 0)
            }
        }.resume()
    }
}
