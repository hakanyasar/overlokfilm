//
//  WatchlistsVcViewModel.swift
//  overlokfilm2
//
//  Created by hyasar on 27.12.2022.
//

import Foundation


protocol WatchlistsVcViewModelProtocol{
    
    func numberOfRowsInSection () -> Int
    func postAtIndex (index : Int) -> PostViewModel
    
}


struct WatchlistsVcViewModel : WatchlistsVcViewModelProtocol{
    
    var postList : [Post]
    
}


extension WatchlistsVcViewModel{
    
    func numberOfRowsInSection() -> Int {
        self.postList.count
    }
    
    func postAtIndex (index : Int) -> PostViewModel {
        
        let post = self.postList[index]
        return PostViewModel(post: post)
    }
    
}
