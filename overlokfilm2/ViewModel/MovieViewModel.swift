//
//  MovieViewModel.swift
//  overlokfilm2
//
//  Created by hyasar on 23.11.2022.
//

import Foundation

struct MovieViewModel {
    
    let movie : Movie
    
    var movieName : String{
        return self.movie.movieName
    }
    var movieYear : String{
        return self.movie.movieYear
    }
    var movieDirector : String{
        return self.movie.movieDirector
    }
    var movieComment : String{
        return self.movie.movieComment
    }
    var postDate : String{
        return self.movie.postDate
    }
    var postedBy : String{
        return self.movie.postedBy
    }
    
}
