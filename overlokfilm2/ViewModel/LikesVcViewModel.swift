//
//  LikesVcViewModel.swift
//  overlokfilm2
//
//  Created by hyasar on 25.12.2022.
//

import Foundation


protocol LikesVcViewModelProtocol{
    
    func numberOfRowsInSection () -> Int
    func postAtIndex (index : Int) -> PostViewModel
    
}



struct LikesVcViewModel : LikesVcViewModelProtocol {
    
    var postList : [Post]
}


extension LikesVcViewModel{
    
    func numberOfRowsInSection() -> Int {
        self.postList.count
    }
    
    func postAtIndex (index : Int) -> PostViewModel {
        
        let post = self.postList[index]
        return PostViewModel(post: post)
        
    }
    
}
