//
//  PostViewModel.swift
//  overlokfilm2
//
//  Created by hyasar on 7.11.2022.
//

import Foundation


struct PostViewModel {
    
    let post : Post
    
    var postId : String {
        return self.post.postId
    }
    var postImageUrl : String {
        return self.post.postImageUrl
    }
    var userIconUrl : String {
        return self.post.userIconUrl
    }
    var postMovieName : String {
        return self.post.postMovieName
    }
    var postMovieYear : String {
        return self.post.postMovieYear
    }
    var postMovieDirector : String {
        return self.post.postMovieDirector
    }
    var postMovieComment : String {
        return self.post.postMovieComment
    }
    var postDate : String {
        return self.post.postDate
    }
    var postedBy : String {
        return self.post.postedBy
    }
    var isLiked : Bool {
        return self.post.isLiked
    }
    
    
}
