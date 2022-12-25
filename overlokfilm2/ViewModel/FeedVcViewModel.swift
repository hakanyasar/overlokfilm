//
//  FeedViewModel.swift
//  overlokfilm2
//
//  Created by hyasar on 7.11.2022.
//

import Foundation

protocol FeedVcViewModelProtocol {
    
    func numberOfRowsInSection () -> Int
    func postAtIndex (index : Int) -> PostViewModel
    
}

struct FeedVcViewModel : FeedVcViewModelProtocol {
    
    var postList : [Post]
    
}

extension FeedVcViewModel {
    
    func numberOfRowsInSection() -> Int {
        self.postList.count
    }
    
    func postAtIndex (index : Int) -> PostViewModel {
        
        let post = self.postList[index]
        return PostViewModel(post: post)
        
    }
    
}
