//
//  Post.swift
//  overlokfilm2
//
//  Created by hyasar on 7.11.2022.
//

import Foundation
import UIKit

struct Post {
    
    var postId : String = ""
    var userIconUrl : String = ""
    var postImageUrl : String = ""
    var postMovieName : String = ""
    var postMovieYear : String = ""
    var postMovieDirector : String = ""
    var postMovieComment : String = ""
    var postedBy : String = ""
    var postDate : String = ""
    var postWatchlistedCount : Int = 0
    var isLiked = Bool()
    
    init (){
        
    }
    
}
