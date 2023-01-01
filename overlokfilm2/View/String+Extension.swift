//
//  String+Extension.swift
//  overlokfilm2
//
//  Created by hyasar on 1.01.2023.
//

import Foundation
import UIKit


extension String {
    
    func trimmingLeadingAndTrailingSpaces(using characterSet: CharacterSet = .whitespacesAndNewlines) -> String {
        return trimmingCharacters(in: characterSet)
    }
    
}
