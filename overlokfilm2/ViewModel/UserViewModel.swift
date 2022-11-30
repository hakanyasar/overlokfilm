//
//  UserViewModel.swift
//  overlokfilm2
//
//  Created by hyasar on 23.11.2022.
//

import Foundation

protocol UserViewModelProtocol {
    
    func numberOfRowsInSection () -> Int
    func postAtIndex (index : Int) -> PostViewModel
    
}

struct UserViewModel : UserViewModelProtocol {
    
    var postList : [Post]
    
}

extension UserViewModel {
    
    func numberOfRowsInSection() -> Int {
        self.postList.count
    }
    
    func postAtIndex (index : Int) -> PostViewModel {
        
        let post = self.postList[index]
        return PostViewModel(post: post)
        
    }
    
}
