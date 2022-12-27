//
//  WatchlistsViewController.swift
//  overlokfilm2
//
//  Created by hyasar on 27.12.2022.
//

import UIKit
import Firebase

class WatchlistsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
      
    @IBOutlet weak var watchlistsTableView: UITableView!
    private var watchlistsViewModel : WatchlistsVcViewModel!
    var watchlistsVSM = WatchlistsViewSingletonModel.sharedInstance
    
    var webService = WebService()
    
    var username = ""
    
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

}
