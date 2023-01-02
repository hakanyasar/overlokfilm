//
//  WatchlistsViewController.swift
//  overlokfilm2
//
//  Created by hyasar on 27.12.2022.
//

import UIKit
import Firebase

final class WatchlistsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
      
    // MARK: - variables
    
    @IBOutlet private weak var watchlistsTableView: UITableView!
    private var watchlistsViewModel : WatchlistsVcViewModel!
    private var watchlistsVSM = WatchlistsViewSingletonModel.sharedInstance
    
    private var webService = WebService()
    
    var username = ""
    
    // MARK: - viewDidLoad and viewWillAppear
    
    override func viewDidLoad() {
        super.viewDidLoad()

        watchlistsTableView.delegate = self
        watchlistsTableView.dataSource = self
        
        //page refresh
        watchlistsTableView.refreshControl = UIRefreshControl()
        watchlistsTableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        getData()
    }
    
    
    // MARK: - tableView functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.watchlistsViewModel == nil ? 0 : self.watchlistsViewModel.numberOfRowsInSection()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = watchlistsTableView.dequeueReusableCell(withIdentifier: "cellOfWatchlists", for: indexPath) as! WatchlistsCell
        
        let postViewModel = self.watchlistsViewModel.postAtIndex(index: indexPath.row)
        
        cell.filmLabel.text = "\(indexPath.row + 1) - " + "\(postViewModel.postMovieName)" + " (\(postViewModel.postMovieYear))"
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let postViewModel = self.watchlistsViewModel.postAtIndex(index: indexPath.row)
        
        watchlistsVSM.postId = postViewModel.postId
        
        performSegue(withIdentifier: "toPostDetailVCFromWatchlists", sender: indexPath)
        
        // this command prevent gray colour when come back after selection
        watchlistsTableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toPostDetailVCFromWatchlists" {
            
            let destinationVC = segue.destination as! PostDetailViewController
            
            destinationVC.postId = watchlistsVSM.postId
            
        }
    }
    
    func getData(){
        
        getUserId(username: self.username) { userId in
            
            self.webService.downloadDataWatchlistsVC(userId: userId) { postList in
                
                self.watchlistsViewModel = WatchlistsVcViewModel(postList: postList)
                
                DispatchQueue.main.async {
                    
                    self.watchlistsViewModel.postList.sort { p1, p2 in
                        
                        return p1.postDate.compare(p2.postDate) == .orderedDescending
                    }
                }
                
                DispatchQueue.main.async {
                    
                    self.watchlistsTableView.reloadData()
                }
            }
        }
        
    }
    
    
    func getUserId(username: String, completion: @escaping (String) -> Void) {
                
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("users").whereField("username", isEqualTo: "\(username)").getDocuments(source: .server) { snapshot, error in
            
            if error != nil {
                
                print(error?.localizedDescription ?? "error")
                self.makeAlert(titleInput: "error", messageInput: "\npage couldn't load. \nplease try again later.")
            }else {
                                    
                DispatchQueue.global().async {
                    
                    for document in snapshot!.documents {
                            
                            let userId = document.documentID
                            completion(userId)
                    }
                    
                }
                      
            }
            
        }
        
    }
    
    @objc private func didPullToRefresh(){
        
        getData()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            
            self.watchlistsTableView.refreshControl?.endRefreshing()
        }
    }

    // MARK: makeAlert
    
    func makeAlert(titleInput: String, messageInput: String){
        
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
}
