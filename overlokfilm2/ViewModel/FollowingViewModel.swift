//
//  FollowingViewModel.swift
//  overlokfilm2
//
//  Created by hyasar on 26.11.2022.
//

import Foundation

protocol FollowingViewModelProtocol{
    
    func numberOfRowsInSection () -> Int
    func postAtIndex (index : Int) -> PostViewModel
    
}

struct FollowingViewModel : FollowingViewModelProtocol{
    
    
    var postList : [Post]
    
}


extension FollowingViewModel{
    
    func numberOfRowsInSection() -> Int {
        self.postList.count
    }
    
    func postAtIndex (index : Int) -> PostViewModel {
        
        let post = self.postList[index]
        return PostViewModel(post: post)
        
    }
    
}
