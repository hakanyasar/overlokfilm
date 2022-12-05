//
//  FeedViewController.swift
//  overlokfilm2
//
//  Created by hyasar on 7.11.2022.
//

import Foundation
import Firebase
import UIKit


class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    private var feedViewModel : FeedViewModel!
    var webService = WebService()
    var feedVSM = FeedViewSingletonModel.sharedInstance
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getData()
        
        //page refresh
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
    }
  
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.feedViewModel == nil ? 0 : self.feedViewModel.numberOfRowsInSection()
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellOfFeed", for: indexPath) as! FeedCell
        
        let postViewModel = self.feedViewModel.postAtIndex(index: indexPath.row)
        
        cell.movieNameLabel.text = "\(postViewModel.postMovieName)" + " (\(postViewModel.postMovieYear))"
        cell.directorNameLabel.text = postViewModel.postMovieDirector
        cell.commentLabel.text = postViewModel.postMovieComment
        cell.dateLabel.text = postViewModel.postDate
        cell.usernameLabel.text = postViewModel.postedBy
        //cell.userImage.image = UIImage(named: "userImageIconLight.png")
        
        
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        let postViewModel = self.feedViewModel.postAtIndex(index: indexPath.row)
                
        feedVSM = FeedViewSingletonModel.sharedInstance
        
        feedVSM.postId = postViewModel.postId
                
        performSegue(withIdentifier: "toPostDetailVCFromFeed", sender: indexPath)
        
        // this command prevent gray colour when come back after selection
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toPostDetailVCFromFeed" {
            
            let destinationVC = segue.destination as! PostDetailViewController
            
            destinationVC.postId = feedVSM.postId
            
        }
        
    }
    
    func getData() {
        
        webService.downloadData { postList in
                
            self.feedViewModel = FeedViewModel(postList: postList)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }

    
    
    @objc private func didPullToRefresh(){
        
        getData()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    
    func makeAlert (titleInput: String, messageInput: String){
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "tamam", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
}


extension FeedViewController : FeedButtonsDelegate {

    
    func likeButtonDidTap(cell: FeedCell) {
        
    }
    
    func watchListButtonDidTap(cell: FeedCell) {
        
        
        
    }
    
    func threeDotMenuButtonDidTap(cell : FeedCell) {
                             
        // compare current userId and post's userId
        
        if tableView.indexPath(for: cell) != nil {
                        
            let cuid = Auth.auth().currentUser?.uid as? String
        
            let username = cell.usernameLabel.text
            
            let firestoreDb = Firestore.firestore()
            
            firestoreDb.collection("users").whereField("username", isEqualTo: "\(String(describing: username ?? "overlokcu"))").getDocuments { snapshot, error in
                
                if error != nil {
                    
                    print(error?.localizedDescription ?? "error")
                    
                }else {
                    
                    if snapshot?.isEmpty != true && snapshot != nil {
                        
                        DispatchQueue.global().async {
                            
                            for document in snapshot!.documents {
                                
                                let docId = document.documentID
                                
                                if docId == cuid {
                                    
                                    self.threeDotMenuButtonAlertForCurrentUser()
                                }else{
                                    
                                    self.threeDotMenuButtonAlertForOrdinaryUser()
                                }
                                
                            }
                            
                            
                        }
                        
                    }
                    
                }
                
            }
            
            
        }
        
    }
    
    func threeDotMenuButtonAlertForCurrentUser(){
             
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "share", style: .default, handler: { action in
            
        }))
        
        alert.addAction(UIAlertAction(title: "edit", style: .default, handler: { action in
            
            self.performSegue(withIdentifier: "toSaveVCForEdit", sender: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "delete", style: .destructive, handler: { action in
            
            
        }))
        
        
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func threeDotMenuButtonAlertForOrdinaryUser(){
                
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "share", style: .default, handler: { uialertaction in
            
        }))
        
        alert.addAction(UIAlertAction(title: "report", style: .default, handler: { uialertaction in
            
        }))
        
        
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
}

