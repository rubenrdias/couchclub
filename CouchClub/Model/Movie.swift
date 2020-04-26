//
//  Movie.swift
//  CouchClub
//
//  Created by Ruben Dias on 26/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

struct Movie: Decodable {
    
    let uuid: String
    let title: String
    let released: String
    let runtime: String
    let genre: String
    let imdbRating: String
    let plot: String
    let actors: String
    let director: String
    let writer: String
    let producer: String
    let awards: String
    let poster: String
    let boxOffice: String
    
    enum CodingKeys: String, CodingKey {
        case uuid = "imdbID"
        case title = "Title"
        case released = "Released"
        case runtime = "Runtime"
        case genre = "Genre"
        case imdbRating = "imdbRating"
        case plot = "Plot"
        case actors = "Actors"
        case director = "Director"
        case writer = "Writer"
        case producer = "Production"
        case awards = "Awards"
        case poster = "Poster"
        case boxOffice = "BoxOffice"
    }
}
