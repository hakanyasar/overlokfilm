//
//  UserViewModel.swift
//  overlokfilm2
//
//  Created by hyasar on 19.12.2022.
//

import Foundation

struct UserViewModel {
    
    let user : User
    
    var userId : String {
        return self.user.userId
    }
    var username : String {
        return self.user.username
    }
    var email : String {
        return self.user.email
    }
    var profileImageUrl : String {
        return self.user.profileImageUrl
    }
    var bio : String {
        return self.user.bio
    }
    var postCount : Int {
        return self.user.postCount
    }
    var followersCount : Int {
        return self.user.followersCount
    }
    var followingCount : Int {
        return self.user.followingCount
    }
    
    
}
