//
//  JustUserViewModel.swift
//  overlokfilm2
//
//  Created by hyasar on 20.12.2022.
//

import Foundation


protocol JustUserViewModelProtocol {
    
    //func getUser() -> UserViewModel
}

struct JustUserViewModel : JustUserViewModelProtocol{
    
    var user : User
    
}

extension  JustUserViewModel {
    /*
    func getUser() -> UserViewModel {
        
        let user = self.user
        return UserViewModel(user: user)
    }
    */
}
