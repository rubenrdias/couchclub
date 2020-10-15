//
//  Show+CoreDataClass.swift
//  CouchClub
//
//  Created by Ruben Dias on 28/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Show)
public class Show: Item {

}

class ShowBuilder {
    
    private var show: Show
    
    init() {
        self.show = Show(context: LocalDatabase.shared.context)
    }
    
    func withID(_ id: String) -> ShowBuilder {
        self.show.id = id
        return self
    }
    
    func named(_ title: String) -> ShowBuilder {
        self.show.title = title
        return self
    }
    
    func fromYear(_ year: String) -> ShowBuilder {
        self.show.year = year
        return self
    }
    
    func rated(_ rated: String) -> ShowBuilder {
        self.show.rated = rated
        return self
    }
    
    func releasedOn(_ released: String) -> ShowBuilder {
        self.show.released = released
        return self
    }
    
    func withRuntime(_ runtime: String) -> ShowBuilder {
        self.show.runtime = runtime
        return self
    }
    
    func withinGenre(_ genre: String) -> ShowBuilder {
        self.show.genre = genre
        return self
    }
    
    func directedBy(_ director: String) -> ShowBuilder {
        self.show.director = director
        return self
    }
    
    func writtenBy(_ writer: String) -> ShowBuilder {
        self.show.writer = writer
        return self
    }
    
    func withActors(_ actors: String) -> ShowBuilder {
        self.show.actors = actors
        return self
    }
    
    func withPlot(_ plot: String) -> ShowBuilder {
        self.show.plot = plot
        return self
    }
    
    func awardedWith(_ awards: String) -> ShowBuilder {
        self.show.awards = awards
        return self
    }
    
    func withPoster(_ poster: String) -> ShowBuilder {
        self.show.poster = poster
        return self
    }
    
    func withRating(_ rating: String) -> ShowBuilder {
        self.show.imdbRating = rating
        return self
    }
    
    func wasWatched(_ watched: Bool) -> ShowBuilder {
        self.show.watched = watched
        return self
    }
    
    func withTotalSeasons(_ seasons: String) -> ShowBuilder {
        self.show.totalSeasons = seasons
        return self
    }
    
    func build() -> Show {
        LocalDatabase.shared.saveContext()
        return self.show
    }
    
}
