//
//  FollowingPaginationSingletonModel.swift
//  overlokfilm2
//
//  Created by hyasar on 7.01.2023.
//

import Foundation
import Firebase

class FollowingPaginationSingletonModel{
    
    static let sharedInstance = FollowingPaginationSingletonModel()
    
    var lastPost : DocumentSnapshot?
    var postSize = 10
    var isFinishedPaging = false
    
    private init(){}
    
    
}
