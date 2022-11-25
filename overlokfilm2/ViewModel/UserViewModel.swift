//
//  UserViewModel.swift
//  overlokfilm2
//
//  Created by hyasar on 23.11.2022.
//

import Foundation

protocol UserViewModelProtocol {
    
    func numberOfRowsInSection () -> Int
    func postAtIndex (index : Int) -> MovieViewModel
    
}

struct UserViewModel : UserViewModelProtocol {
    
    var movieList : [Movie]
    
}

extension UserViewModel {
    
    func numberOfRowsInSection () -> Int {
        self.movieList.count
    }
    
    func postAtIndex (index : Int) -> MovieViewModel {
        
        let movie = self.movieList[index]
        return MovieViewModel(movie: movie)
    }
    
}
