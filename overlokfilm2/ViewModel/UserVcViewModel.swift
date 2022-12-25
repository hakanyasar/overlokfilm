//
//  UserViewModel.swift
//  overlokfilm2
//
//  Created by hyasar on 23.11.2022.
//

import Foundation

protocol UserVcViewModelProtocol {
    
    func numberOfRowsInSection () -> Int
    func postAtIndex (index : Int) -> PostViewModel
    
}

struct UserVcViewModel : UserVcViewModelProtocol {
    
    var postList : [Post]
    
}

extension UserVcViewModel {
    
    func numberOfRowsInSection() -> Int {
        self.postList.count
    }
    
    func postAtIndex (index : Int) -> PostViewModel {
        
        let post = self.postList[index]
        return PostViewModel(post: post)
        
    }
    
}
