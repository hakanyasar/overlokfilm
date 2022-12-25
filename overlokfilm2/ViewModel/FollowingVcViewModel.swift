//
//  FollowingViewModel.swift
//  overlokfilm2
//
//  Created by hyasar on 26.11.2022.
//

import Foundation

protocol FollowingVcViewModelProtocol{
    
    func numberOfRowsInSection () -> Int
    func postAtIndex (index : Int) -> PostViewModel
    
}

struct FollowingVcViewModel : FollowingVcViewModelProtocol{
    
    var postList : [Post]
    
}

extension FollowingVcViewModel{
    
    func numberOfRowsInSection() -> Int {
        self.postList.count
    }
    
    func postAtIndex (index : Int) -> PostViewModel {
        
        let post = self.postList[index]
        return PostViewModel(post: post)
        
    }
    
}
