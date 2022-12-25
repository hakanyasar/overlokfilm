//
//  PaginationSingletonModel.swift
//  overlokfilm2
//
//  Created by hyasar on 23.12.2022.
//

import Foundation
import Firebase

class PaginationSingletonModel{
    
    
    static let sharedInstance = PaginationSingletonModel()
    
    var lastPost : DocumentSnapshot?
    var postSize = 2
    var isPaginating = false
    
    private init(){}
    
}
