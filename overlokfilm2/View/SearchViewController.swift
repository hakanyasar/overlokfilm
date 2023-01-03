//
//  SearchViewController.swift
//  overlokfilm2
//
//  Created by hyasar on 7.11.2022.
//

import UIKit

final class SearchViewController: UIViewController, UISearchBarDelegate {
    
   
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchBar.delegate = self
        
        searchBar.autocapitalizationType = .none
        navigationItem.titleView = searchBar
        
        // FIXME: - select something to become first responder except searchBar
        
    }
    
    /*
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        performSegue(withIdentifier: "toSearchDetailVC", sender: nil)
    }
    */
     
    /*
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        performSegue(withIdentifier: "toSearchDetailVC", sender: nil)
    }
     */
    
}
