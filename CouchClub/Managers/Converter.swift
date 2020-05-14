//
//  File.swift
//  CouchClub
//
//  Created by Ruben Dias on 28/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import CoreData

class Converter {
    
    static let shared = Converter()
    
    private init() {}
    
    func toMovie(_ item: SearchItemMovie) -> Movie {
        let builder = MovieBuilder()
        let movie = builder.withID(item.id)
            .named(item.title)
            .fromYear(item.year)
            .rated(item.rated)
            .releasedOn(item.released)
            .withRuntime(item.runtime)
            .withinGenre(item.genre)
            .directedBy(item.director)
            .writtenBy(item.writer)
            .withActors(item.actors)
            .withPlot(item.plot)
            .awardedWith(item.awards)
            .withPoster(item.poster)
            .withRating(item.imdbRating)
            .withBoxOffice(item.boxOffice)
            .producedBy(item.producer)
            .wasWatched(false)
            .build()
        
        return movie
    }
    
    func toShow(_ item: SearchItemShow) -> Show {
        let builder = ShowBuilder()
        let show = builder.withID(item.id)
            .named(item.title)
            .fromYear(item.year)
            .rated(item.rated)
            .releasedOn(item.released)
            .withRuntime(item.runtime)
            .withinGenre(item.genre)
            .directedBy(item.director)
            .writtenBy(item.writer)
            .withActors(item.actors)
            .withPlot(item.plot)
            .awardedWith(item.awards)
            .withPoster(item.poster)
            .withRating(item.imdbRating)
            .withTotalSeasons(item.totalSeasons)
            .wasWatched(false)
            .build()
        
        return show
    }
    
}
