//
//  UploadViewSingletonModel.swift
//  overlokfilm2
//
//  Created by hyasar on 18.11.2022.
//

import Foundation
import UIKit

class UploadViewSingletonModel {
    
    static let sharedInstance = UploadViewSingletonModel()
    
    var imageView = UIImage()
    var movieName = ""
    var movieYear = ""
    var movieDirector = ""
    var comment = ""
    
    private init() {}
    
}
