//
//  FollowingViewController.swift
//  overlokfilm2
//
//  Created by hyasar on 7.11.2022.
//

import Foundation
import UIKit
import Firebase

class FollowingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FollowingFeedCellDelegate {

    
    @IBOutlet weak var followingTableView: UITableView!
    
    private var followingViewModel : FollowingVcViewModel!
    var webService = WebService()
    var followingVSM = FollowingViewSingletonModel.sharedInstance
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        followingTableView.delegate = self
        followingTableView.dataSource = self
        
        //getData()
        
        //page refresh
        followingTableView.refreshControl = UIRefreshControl()
        followingTableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        getData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return self.followingViewModel == nil ? 0 : self.followingViewModel.numberOfRowsInSection()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = followingTableView.dequeueReusableCell(withIdentifier: "cellOfFollowing", for: indexPath) as! FollowingFeedCell
        
        let postViewModel = self.followingViewModel.postAtIndex(index: indexPath.row)
        
        cell.movieNameLabel.text = "\(postViewModel.postMovieName)" + " (\(postViewModel.postMovieYear))"
        cell.directorNameLabel.text = postViewModel.postMovieDirector
        cell.commentLabel.text = postViewModel.postMovieComment
        cell.dateLabel.text = postViewModel.postDate
        cell.usernameLabel.text = postViewModel.postedBy
        cell.userImage.sd_setImage(with: URL(string: postViewModel.userIconUrl))
        
        isItLikedBefore(postId: postViewModel.post.postId) { result in
            
            if result == true{
                
                cell.isLikedCheck = true
                cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                
            }else{
                
                cell.isLikedCheck = false
                cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            }
        }
        
        isItWatchlistedBefore(postId: postViewModel.post.postId) { result in
            if result == true{
                
                cell.isWatchlistedCheck = true
                cell.watchListButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
            }else{
                
                cell.isWatchlistedCheck = false
                cell.watchListButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
            }
        }
        
        let gestureRecognizer = CustomTapGestureRecog(target: self, action: #selector(userImageTapped))
        let gestureRecognizer2 = CustomTapGestureRecog(target: self, action: #selector(usernameLabelTapped))
        cell.userImage.addGestureRecognizer(gestureRecognizer)
        cell.usernameLabel.addGestureRecognizer(gestureRecognizer2)
        gestureRecognizer.username = cell.usernameLabel.text!
        gestureRecognizer2.username = cell.usernameLabel.text!
        
        cell.delegate = self
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let postViewModel = self.followingViewModel.postAtIndex(index: indexPath.row)
        
        followingVSM.postId = postViewModel.postId
        
        performSegue(withIdentifier: "toPostDetailVCFromFollowing", sender: nil)
        
        // this command prevent gray colour when come back after selection
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toPostDetailVCFromFollowing" {
            
            let destinationVC = segue.destination as! PostDetailViewController
            
            destinationVC.postId = followingVSM.postId
        }
        
        if segue.identifier == "toUserVCFromFollowingVC" {
            
            let destinationVC = segue.destination as! UserViewController
            
            destinationVC.username = sender as! String
        }
        
    }
    
    
    func getData(){
        
        webService.downloadDataFollowingVC { postList in
            
            self.followingViewModel = FollowingVcViewModel(postList: postList)
            
            DispatchQueue.main.async {
                
                self.followingViewModel.postList.sort { p1, p2 in
                    
                    return p1.postDate.compare(p2.postDate) == .orderedDescending
                }
            }
            
            DispatchQueue.main.async {
                
                self.followingTableView.reloadData()
            }
            
        }
        
    }
    
    func likeButtonDidTap(cell: FollowingFeedCell) {
        
        guard let indexPath = followingTableView.indexPath(for: cell) else {return}
        var post = self.followingViewModel.postList[indexPath.item]
        let postID = post.postId
        
        guard let cuid = Auth.auth().currentUser?.uid as? String else { return }
                
        if cell.isLikedCheck == true{
            
            // if we liked this post before we can unliked now
            print("\n we unliked \n")
            let firestoreDatabase = Firestore.firestore()
            
            DispatchQueue.global().async {
                
                firestoreDatabase.collection("likes").document("\(cuid)").updateData(["\(postID)" : FieldValue.delete()]) { error in
                    
                    if let error = error {
                        
                        print("error: \(error.localizedDescription)")
                        
                    }else {
                        
                        DispatchQueue.main.async {
                            
                            cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                            cell.isLikedCheck = false
                        }
                    }
                }
            }
            
        }else if cell.isLikedCheck == false{
            
            print("\n we liked \n")
            
            // if we never liked this post before we can liked now
                        
            let firestoreDatabase = Firestore.firestore()
            
            let ref = firestoreDatabase.collection("likes").document(cuid)
            
            let values = [postID: 1]
            
            DispatchQueue.global().async {
                
                ref.setData(values, merge: true) { error in
                    
                    if error != nil {
                        
                        print(error?.localizedDescription ?? "error")
                        
                    }else {
                        
                        DispatchQueue.main.async {
                            
                            print("hearth.fill e girdik")
                            cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                            cell.isLikedCheck = true
                        }
                    }
                }
            }
            
        }
       
        
    }
    
    func watchListButtonDidTap(cell: FollowingFeedCell) {
                
        guard let indexPath = followingTableView.indexPath(for: cell) else {return}
        var post = self.followingViewModel.postList[indexPath.item]
        let postID = post.postId
        
        guard let cuid = Auth.auth().currentUser?.uid as? String else { return }
                
        if cell.isWatchlistedCheck == true{
            
            // if we add to watchlist this post before we can unwatchlist now
            print("\n we removed from watchlist \n")
            let firestoreDatabase = Firestore.firestore()
            
            DispatchQueue.global().async {
                
                firestoreDatabase.collection("watchlists").document("\(cuid)").updateData(["\(postID)" : FieldValue.delete()]) { error in
                    
                    if let error = error {
                        
                        print("error: \(error.localizedDescription)")
                        
                    }else {
                        
                        DispatchQueue.main.async {
                            
                            cell.watchListButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
                            cell.isWatchlistedCheck = false
                        }
                    }
                }
            }
            
        }else if cell.isWatchlistedCheck == false{
            
            print("\n we added to watchlist \n")
            
            // if we never add to watchlist this post before we can add to watchlist now
                        
            let firestoreDatabase = Firestore.firestore()
            
            let ref = firestoreDatabase.collection("watchlists").document(cuid)
            
            let values = [postID: 1]
            
            DispatchQueue.global().async {
                
                ref.setData(values, merge: true) { error in
                    
                    if error != nil {
                        
                        print(error?.localizedDescription ?? "error")
                        
                    }else {
                        
                        DispatchQueue.main.async {
                            
                            cell.watchListButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
                            cell.isWatchlistedCheck = true
                        }
                    }
                }
            }
            
        }

    }
    
    func threeDotMenuButtonDidTap(cell: FollowingFeedCell) {
                                
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
                    
  
    @objc func userImageTapped(sender: CustomTapGestureRecog) {
        
        let username = sender.username
        
        performSegue(withIdentifier: "toUserVCFromFollowingVC", sender: username)
    }
    
    
    @objc func usernameLabelTapped(sender: CustomTapGestureRecog) {
        
        let username = sender.username
        
        performSegue(withIdentifier: "toUserVCFromFollowingVC", sender: username)
    }
    
    @objc private func didPullToRefresh(){
        
        getData()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            
            self.followingTableView.refreshControl?.endRefreshing()
        }
    }
    
    
    func makeAlert (titleInput: String, messageInput: String){
        
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func isItWatchlistedBefore(postId : String, completion: @escaping (Bool) -> Void){
        
        guard let cuid = Auth.auth().currentUser?.uid as? String else { return }
        
        let firestoreDatabase = Firestore.firestore()
            
            firestoreDatabase.collection("watchlists").document(cuid).getDocument(source: .server) { document, error in
                
                if error != nil {
                    
                    print(error?.localizedDescription ?? "error")
                    
                }else {
                    
                    if let document = document, document.exists {
                                                 
                        if let postID = document.get("\(postId)") as? Int {
                            
                            completion(true)
                        }else{
                            
                            completion(false)
                        }
                    }else {
                        
                        completion(false)
                    }
                }
            }
    }
    
    func isItLikedBefore(postId : String, completion: @escaping (Bool) -> Void){
                
        guard let cuid = Auth.auth().currentUser?.uid as? String else { return }
        
        let firestoreDatabase = Firestore.firestore()
            
            firestoreDatabase.collection("likes").document(cuid).getDocument(source: .server) { document, error in
                
                if error != nil {
                    
                    print(error?.localizedDescription ?? "error")
                    
                }else {
                    
                    if let document = document, document.exists {
                                                 
                        if let postID = document.get("\(postId)") as? Int {
                            
                            completion(true)
                        }else{
                            
                            completion(false)
                        }
                        
                    }else {
                        
                        completion(false)
                    }
                    
                }
                
            }
    }
    

}


class CustomTapGestureRecog: UITapGestureRecognizer {
    
    var username = String()
}

