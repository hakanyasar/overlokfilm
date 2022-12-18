//
//  FollowingViewSingletonModel.swift
//  overlokfilm2
//
//  Created by hyasar on 15.12.2022.
//

import Foundation


class FollowingViewSingletonModel {
    
    static let sharedInstance = FollowingViewSingletonModel()
    
    var postId = ""
    
    private init(){}
    
}
