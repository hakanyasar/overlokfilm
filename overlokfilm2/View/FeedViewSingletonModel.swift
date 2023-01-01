//
//  FeedViewSingletonModel.swift
//  overlokfilm2
//
//  Created by hyasar on 30.11.2022.
//

import Foundation


final class FeedViewSingletonModel {
    
    static let sharedInstance = FeedViewSingletonModel()
    
    var postId = ""
    
    private init(){}
    
}
