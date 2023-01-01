//
//  WatchlistsViewSingletonModel.swift
//  overlokfilm2
//
//  Created by hyasar on 27.12.2022.
//

import Foundation

final class WatchlistsViewSingletonModel {
    
    static let sharedInstance = WatchlistsViewSingletonModel()
    
    var postId = ""
    
    private init(){}
    
}
