//
//  BlocklistVcViewModel.swift
//  overlokfilm2
//
//  Created by hyasar on 2.04.2023.
//

import Foundation


protocol BlocklistVcViewModelProtocol{
    
    func numberOfRowsInSection () -> Int
    
}

struct BlocklistVcViewModel {
    
    var usernameList : [String]
    
}

extension BlocklistVcViewModel{
    
    func numberOfRowsInSection() -> Int {
        self.usernameList.count
    }
    
}
