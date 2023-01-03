//
//  SearchDetailViewController.swift
//  overlokfilm2
//
//  Created by hyasar on 2.01.2023.
//

import UIKit

class SearchDetailViewController: UIViewController {

    
    @IBOutlet var searchBar: UISearchBar!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.becomeFirstResponder()
        
        searchBar.autocapitalizationType = .none
        navigationItem.titleView = searchBar
        
    }
    

   

}
