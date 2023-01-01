//
//  UserViewSingletonModel.swift
//  overlokfilm2
//
//  Created by hyasar on 30.11.2022.
//

import Foundation

final class UserViewSingletonModel {
    
    static let sharedInstance = UserViewSingletonModel()
    
    var postId = ""
    
    private init(){}
}
