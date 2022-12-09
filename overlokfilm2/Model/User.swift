//
//  User.swift
//  overlokfilm2
//
//  Created by hyasar on 7.11.2022.
//

import Foundation


struct User {
    
    var userId : String
    var username : String
    var email : String
    var profileImageUrl : String
    
    init(userId : String, dictionary : [String : Any]) {
     
        self.userId = userId
        self.username = dictionary["username"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        
    }
    
}
