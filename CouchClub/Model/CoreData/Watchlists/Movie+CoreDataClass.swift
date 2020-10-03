//
//  Movie+CoreDataClass.swift
//  CouchClub
//
//  Created by Ruben Dias on 28/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Movie)
public class Movie: Item {
    
}

class MovieBuilder {
    
    var movie: Movie
    
    init() {
        self.movie = Movie(context: LocalDatabase.shared.context)
    }
    
    func withID(_ id: String) -> MovieBuilder {
        self.movie.id = id
        return self
    }
    
    func named(_ title: String) -> MovieBuilder {
        self.movie.title = title
        return self
    }
    
    func fromYear(_ year: String) -> MovieBuilder {
        self.movie.year = year
        return self
    }
    
    func rated(_ rated: String) -> MovieBuilder {
        self.movie.rated = rated
        return self
    }
    
    func releasedOn(_ released: String) -> MovieBuilder {
        self.movie.released = released
        return self
    }
    
    func withRuntime(_ runtime: String) -> MovieBuilder {
        self.movie.runtime = runtime
        return self
    }
    
    func withinGenre(_ genre: String) -> MovieBuilder {
        self.movie.genre = genre
        return self
    }
    
    func directedBy(_ director: String) -> MovieBuilder {
        self.movie.director = director
        return self
    }
    
    func writtenBy(_ writer: String) -> MovieBuilder {
        self.movie.writer = writer
        return self
    }
    
    func withActors(_ actors: String) -> MovieBuilder {
        self.movie.actors = actors
        return self
    }
    
    func withPlot(_ plot: String) -> MovieBuilder {
        self.movie.plot = plot
        return self
    }
    
    func awardedWith(_ awards: String) -> MovieBuilder {
        self.movie.awards = awards
        return self
    }
    
    func withPoster(_ poster: String) -> MovieBuilder {
        self.movie.poster = poster
        return self
    }
    
    func withRating(_ rating: String) -> MovieBuilder {
        self.movie.imdbRating = rating
        return self
    }
    
    func wasWatched(_ watched: Bool) -> MovieBuilder {
        self.movie.watched = watched
        return self
    }
    
    func producedBy(_ producer: String) -> MovieBuilder {
        self.movie.production = producer
        return self
    }
    
    func withBoxOffice(_ boxOffice: String) -> MovieBuilder {
        self.movie.boxOffice = boxOffice
        return self
    }
    
    func build() -> Movie {
        LocalDatabase.shared.saveContext()
        return self.movie
    }
    
}
