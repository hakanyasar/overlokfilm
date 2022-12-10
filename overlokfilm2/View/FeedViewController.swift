//
//  FeedViewController.swift
//  overlokfilm2
//
//  Created by hyasar on 7.11.2022.
//

import Foundation
import Firebase
import UIKit


class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FeedCellDelegate  {

    
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
        cell.userImage.sd_setImage(with: URL(string: postViewModel.userIconUrl))
        
        let gestureRecognizer = CustomTapGestureRec(target: self, action: #selector(userImageTapped))
        let gestureRecognizer2 = CustomTapGestureRec(target: self, action: #selector(usernameLabelTapped))
        cell.userImage.addGestureRecognizer(gestureRecognizer)
        cell.usernameLabel.addGestureRecognizer(gestureRecognizer2)
        gestureRecognizer.username = cell.usernameLabel.text!
        gestureRecognizer2.username = cell.usernameLabel.text!
        
        cell.delegate = self
        cell.postId = postViewModel.postId
        
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
        
        if segue.identifier == "toUserViewController" {
            
            let destinationVC = segue.destination as! UserViewController
            
            destinationVC.username = sender as! String
        }
        
        if segue.identifier == "toSaveVCForEdit" {
            
            let destinationVC = segue.destination as! SaveViewController
            
            destinationVC.postIdWillEdit = sender as! String
            
        }
        
    }
    
    @objc func userImageTapped(sender: CustomTapGestureRec) {
        
        let username = sender.username
        
        performSegue(withIdentifier: "toUserViewController", sender: username)
    }
    
    
    @objc func usernameLabelTapped(sender: CustomTapGestureRec) {
        
        let username = sender.username
        
        print("pacino: \(username)")
        
        performSegue(withIdentifier: "toUserViewController", sender: nil)
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
        let okButton = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func likeButtonDidTap(cell: FeedCell) {
        
        print("like button tapped")
        
        print("in like button cell.postId: \(cell.postId)")
        
    }
    
    func watchListButtonDidTap(cell: FeedCell) {
        
        print("watchlist button tapped")
    }
    
    func threeDotMenuButtonDidTap(cell: FeedCell) {
        
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
                                    
                                    // forCurrentUser
                                    
                                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                                    
                                    let shareButton = UIAlertAction(title: "share", style: .default)
                                    
                                    let editButton = UIAlertAction(title: "edit", style: .default) { action in
                                        
                                        self.performSegue(withIdentifier: "toSaveVCForEdit", sender: cell.postId)
                                    }
                                    let deleteButton = UIAlertAction(title: "delete", style: .destructive) { action in
                                        
                                        let alerto = UIAlertController(title: "", message: "are you sure for deleting?", preferredStyle: .alert)
                                        
                                        let deleteButton = UIAlertAction(title: "yes, delete", style: .destructive) { action in
                                            
                                            // firstly, we are deleting post from firestore
                                            
                                            var postIdWillDelete = cell.postId
                                            
                                            firestoreDb.collection("posts").whereField("postId", isEqualTo: "\(postIdWillDelete)").getDocuments { snapshot, error in
                                                
                                                if error != nil {
                                                    
                                                    self.makeAlert(titleInput: "error", messageInput: "your post couldn't been deleted. please try later.")
                                                    print(error?.localizedDescription ?? "error")
                                                    
                                                }else {
                                                    
                                                    for document in snapshot!.documents {
                                                        
                                                        document.reference.delete()
                                                    }
                                                    
                                                    // secondly, we are deleting post's image from storage (our image id is the same our postId so this makes our process easy)
                                                    
                                                    let storage = Storage.storage()
                                                    let storageReference = storage.reference()
                                                    
                                                    let imageWillBeDelete = storageReference.child("media").child("\(postIdWillDelete).jpg")
                                                    
                                                    
                                                    imageWillBeDelete.delete { error in
                                                        
                                                        if let error = error {
                                                            
                                                            self.makeAlert(titleInput: "error", messageInput: "your post couldn't been deleted. please try later.")
                                                            print("error: \(error.localizedDescription)")
                                                            
                                                        }else {
                                                                                                                
                                                            DispatchQueue.main.async {
                                                                self.tableView.reloadData()
                                                            }
                                                            
                                                            self.makeAlert(titleInput: "", messageInput: "your post has been deleted.")
                                                        }
                                                    }
                                                    
                                                }
                                                
                                            }
                                          
                                        }
                                        
                                        let cancelButton = UIAlertAction(title: "cancel", style: .cancel)
                                        
                                        alerto.addAction(deleteButton)
                                        alerto.addAction(cancelButton)
                                        
                                        DispatchQueue.main.async {
                                            self.present(alerto, animated: true, completion: nil)
                                        }
                                        
                                    }
                                    
                                    let cancelButton = UIAlertAction(title: "cancel", style: .cancel)
                                    
                                    
                                    alert.addAction(shareButton)
                                    alert.addAction(editButton)
                                    alert.addAction(deleteButton)
                                    alert.addAction(cancelButton)
                                    
                                    DispatchQueue.main.async {
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                    
                                    
                                }else{
                                    
                                    // forClickedUser
                                    
                                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                                    
                                    let sharebutton = UIAlertAction(title: "share", style: .default)
                                    let reportButton =  UIAlertAction(title: "report", style: .default)
                                    let cancelButton =  UIAlertAction(title: "cancel", style: .cancel)
                                    
                                    alert.addAction(sharebutton)
                                    alert.addAction(reportButton)
                                    alert.addAction(cancelButton)
                                    
                                    DispatchQueue.main.async {
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                    
                                }
                                
                            }
                            
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }

 
    
}


class CustomTapGestureRec: UITapGestureRecognizer {
    
    var username = String()
}
