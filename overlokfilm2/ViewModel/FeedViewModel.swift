//
//  FeedViewModel.swift
//  overlokfilm2
//
//  Created by hyasar on 7.11.2022.
//

import Foundation


protocol FeedViewModelProtocol{
    
    func numberOfRowsInSection () -> Int
    func postAtIndex (index : Int) -> PostViewModel
    
}

struct FeedViewModel : FeedViewModelProtocol {
    
    var postList : [Post]
    
}


extension FeedViewModel {
    
    func numberOfRowsInSection() -> Int {
        self.postList.count
    }
    
    func postAtIndex (index : Int) -> PostViewModel {
        
        let post = self.postList[index]
        return PostViewModel(post: post)
        
    }
    
}
