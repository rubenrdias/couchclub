//
//  Constants.swift
//  CouchClub
//
//  Created by Ruben Dias on 28/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

// MARK: - Core Data

let ad = UIApplication.shared.delegate as! AppDelegate
let context = ad.persistentContainer.viewContext

// MARK: - Enums

enum ItemType: String {
    case movie
    case series
}

enum ChatroomType: String {
    case watchlist
    case movie
    case show
}

// MARK: - Date Formatters
let messageSectionFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "EEEE, dd/MMM/yy HH:mm"
    return f
}()
