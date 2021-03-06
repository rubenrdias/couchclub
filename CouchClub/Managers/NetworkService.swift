//
//  NetworkService.swift
//  CouchClub
//
//  Created by Ruben Dias on 26/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

fileprivate struct SearchResult: Decodable {
    
    let results: [SearchItem]
    let totalResults: String
    
    enum CodingKeys: String, CodingKey {
        case results = "Search"
        case totalResults = "totalResults"
    }
    
}

struct SearchItem: Decodable {
    
    let id: String
    let title: String
    let poster: String
    
    enum CodingKeys: String, CodingKey {
        case id = "imdbID"
        case title = "Title"
        case poster = "Poster"
    }
}

final class NetworkService {
    
    static let shared = NetworkService()
    private init() {}
    
    private let urlSession = URLSession.shared
    
    // MARK: - Search
    
    func searchResults(forType type: ItemType, searchText: String, completion: @escaping (_ results: [Any]?, _ totalResults: Int)->()) {
        var url = URLComponents(string: Environment.OMDB_BASE_URL.absoluteString)!
        
        let params = [
            "apikey": Environment.OMDB_API_KEY,
            "s": searchText,
            "type": type.rawValue
        ]
        
        url.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        self.urlSession.dataTask(with: url.url!) { (data, response, error) in
            guard let data = data else {
                if let error = error {
                    print("Failed to fetch search results: \(error.localizedDescription)")
                }
                // TODO: process response
                completion(nil, 0)
                return
            }
            
            let searchResult = try? JSONDecoder().decode(SearchResult.self, from: data)
            if let results = searchResult?.results, let totalResults = Int(searchResult?.totalResults ?? "0") {
                completion(results, totalResults)
            } else {
                completion(nil, 0)
            }
        }.resume()
    }
    
	func searchResult(forID id: String, ofType type: ItemType, completion: @escaping (_ result: Any?, _ error: Error?)->()) {
        var url = URLComponents(string: Environment.OMDB_BASE_URL.absoluteString)!
        
        let params = [
            "apikey": Environment.OMDB_API_KEY,
            "i": id,
            "plot": "full",
            "type": type.rawValue
        ]
        
        url.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        self.urlSession.dataTask(with: url.url!) { (data, response, error) in
            guard let data = data else {
                if let error = error {
                    print("Failed to fetch search result: \(error.localizedDescription)")
                }
                // TODO: process response
                completion(nil, error)
                return
            }
            
            if type == .movie, let movie = try? JSONDecoder().decode(SearchItemMovie.self, from: data) {
                completion(movie, nil)
            } else if type == .series, let show = try? JSONDecoder().decode(SearchItemShow.self, from: data) {
                completion(show, nil)
            } else {
				// TODO: pass in some form of error
				print("Decoder Error | Failed to decode search item into Movie or Show.")
                completion(nil, nil)
            }
        }.resume()
    }
    
    // MARK: - Download
    
    func downloadImage(_ url: URL, completion: @escaping (_ image: UIImage?)->()) {
        self.urlSession.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                if let error = error {
                    print("Failed to download image: \(error.localizedDescription)\n\(url))")
                }
                // TODO: process response
                completion(nil)
                return
            }
            
            let image = UIImage(data: data)
            completion(image)
        }.resume()
    }
}
