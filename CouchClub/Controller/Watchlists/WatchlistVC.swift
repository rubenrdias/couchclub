//
//  WatchlistVC.swift
//  CouchClub
//
//  Created by Ruben Dias on 30/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class WatchlistVC: UICollectionViewController {
    
    var watchlist: Watchlist!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let xPosition = Double(view.bounds.width / 2) - 100
        let yPosition = Double(view.bounds.height / 2) - 25
        let lbl = UILabel(frame: .init(x: xPosition, y: yPosition, width: 200, height: 50))
        lbl.text = watchlist.title
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        view.addSubview(lbl)
    }
    
    deinit {
        print("-- DEINIT -- Watchlist VC")
    }

}

extension WatchlistVC {
    
}
