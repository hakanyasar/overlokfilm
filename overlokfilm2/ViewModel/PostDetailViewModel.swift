//
//  PostDetailViewModel.swift
//  overlokfilm2
//
//  Created by hyasar on 29.11.2022.
//

import Foundation

protocol PostDetailViewModelProtocol{
    
    func numberOfRowsInSection () -> Int
    func postAtIndex (index : Int) -> PostViewModel
    
}


struct PostDetailViewModel : PostDetailViewModelProtocol{
    
    var postList : [Post]
    
}


extension PostDetailViewModel{
    
    func numberOfRowsInSection() -> Int {
        self.postList.count
    }
    
    func postAtIndex (index : Int) -> PostViewModel {
        
        let post = self.postList[index]
        return PostViewModel(post: post)
        
    }
    
}
