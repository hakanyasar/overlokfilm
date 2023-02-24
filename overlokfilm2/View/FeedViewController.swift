//
//  FeedViewController.swift
//  overlokfilm2
//
//  Created by hyasar on 7.11.2022.
//

import Foundation
import Firebase
import FirebaseStorage
import UIKit

// UITableViewDataSourcePrefetching

final class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, FeedCellDelegate {
    
    // MARK: - variables
    
    @IBOutlet weak var tableView: UITableView!
    
    private var feedViewModel : FeedVcViewModel!
    private var webService = WebService()
    private var feedVSM = FeedViewSingletonModel.sharedInstance
    
    private let group = DispatchGroup()
    
    // MARK: - viewDidLoad and viewWillAppear
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.prefetchDataSource = self
                
        //page refresh
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        getData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        FeedPaginationSingletonModel.sharedInstance.isFinishedPaging = false
    }
    
    // MARK: - tableView functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.feedViewModel == nil ? 0 : self.feedViewModel.numberOfRowsInSection()
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellOfFeed", for: indexPath) as! FeedCell
        cell.likeButton.isEnabled = true
        
        let postViewModel = self.feedViewModel.postAtIndex(index: indexPath.row)
        
        cell.movieNameLabel.text = "\(postViewModel.postMovieName)" + " (\(postViewModel.postMovieYear))"
        cell.directorNameLabel.text = postViewModel.postMovieDirector
        cell.commentLabel.text = postViewModel.postMovieComment
        cell.dateLabel.text = postViewModel.postDate
        cell.usernameLabel.text = postViewModel.postedBy
        cell.userImage.sd_setImage(with: URL(string: postViewModel.userIconUrl))
        cell.watchListCountLabel.text = String(postViewModel.postWatchlistedCount)
        
        //print("xx indexPath item = \(indexPath.item)\n")
        //print("xx fedviewCount - 1 = \(self.feedViewModel.postList.count-1)")
        
        if indexPath.item == self.feedViewModel.postList.count-1 && !FeedPaginationSingletonModel.sharedInstance.isFinishedPaging {
            
            self.webService.continuePagesFeed { postList in
                
                self.feedViewModel = FeedVcViewModel(postList: postList)
                
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                }
            }
        }
        
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
        
        let gestureRecognizer = CustomTapGestureRec(target: self, action: #selector(userImageTapped))
        let gestureRecognizer2 = CustomTapGestureRec(target: self, action: #selector(usernameLabelTapped))
        cell.userImage.addGestureRecognizer(gestureRecognizer)
        cell.usernameLabel.addGestureRecognizer(gestureRecognizer2)
        gestureRecognizer.username = cell.usernameLabel.text!
        gestureRecognizer2.username = cell.usernameLabel.text!
        
        
        // we set like button hidden if it is current user's post
        getCurrentUsername { curUsername in
            
            if cell.usernameLabel.text == curUsername {
                
                cell.likeButton.isEnabled = false
                
            }
        }
        
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let postViewModel = self.feedViewModel.postAtIndex(index: indexPath.row)
        
        feedVSM.postId = postViewModel.postId
        
        performSegue(withIdentifier: "toPostDetailVCFromFeed", sender: indexPath)
        
        // this command prevent gray colour when come back after selection
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
        
    // MARK: - functions
    
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
    
    func getData() {
                
        webService.downloadData { postList in
            
            self.feedViewModel = FeedVcViewModel(postList: postList)
            
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
            }
        }
        
    }
    
    
    @objc func userImageTapped(sender: CustomTapGestureRec) {
        
        let username = sender.username
        
        performSegue(withIdentifier: "toUserViewController", sender: username)
    }
    
    
    @objc func usernameLabelTapped(sender: CustomTapGestureRec) {
        
        let username = sender.username
        
        performSegue(withIdentifier: "toUserViewController", sender: username)
    }
    
    
    @objc private func didPullToRefresh(){
        
        getData()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    
    func decreasePostCount(){
        
        guard let cuid = Auth.auth().currentUser?.uid as? String else {return}
        
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("users").document(cuid).getDocument { document, error in
            
            if error != nil{
                
                print("error: \(String(describing: error?.localizedDescription))")
                
            }else {
                
                if let document = document, document.exists {
                    
                    if let postCount = document.get("postCount") as? Int {
                        
                        // we are setting new postCount
                        let postCountDic = ["postCount" : postCount - 1] as [String : Any]
                        
                        firestoreDb.collection("users").document(cuid).setData(postCountDic, merge: true)
                        
                    } else {
                        print("\ndocument field was not gotten")
                    }
                }
                
            }
            
        }
        
    }
    
    func getCurrentUsername(complation: @escaping (String) -> Void) {
        
        guard let cuid = Auth.auth().currentUser?.uid as? String else { return }
        
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("users").document(cuid).getDocument { document, error in
            
            if error != nil{
                
                print("error: \(String(describing: error?.localizedDescription))")
                self.makeAlert(titleInput: "error", messageInput: "\nan error occured. \nplease try again later.")
                
            }else {
                
                if let document = document, document.exists {
                    
                    if let dataDescription = document.get("username") as? String{
                        
                        complation(dataDescription)
                        
                    } else {
                        print("\ndocument field was not gotten")
                    }
                }
                
            }
            
        }
        
    }
    
    
    func likeButtonDidTap(cell: FeedCell) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        var post = self.feedViewModel.postList[indexPath.item]
        let postID = post.postId
        
        guard let cuid = Auth.auth().currentUser?.uid as? String else { return }
        
        if cell.isLikedCheck == true{
            
            // if we liked this post before we can unliked now
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
                            
                            cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                            cell.isLikedCheck = true
                        }
                    }
                }
            }
            
        }
        
    }
    
    func watchListButtonDidTap(cell: FeedCell) {
                
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        var post = self.feedViewModel.postList[indexPath.item]
        let postID = post.postId
        
        guard let cuid = Auth.auth().currentUser?.uid as? String else { return }
        
        if cell.isWatchlistedCheck == true{
            
            // if we add to watchlist this post before we can unwatchlist now
            let firestoreDatabase = Firestore.firestore()
            
            DispatchQueue.global().async {
                
                firestoreDatabase.collection("watchlists").document("\(cuid)").updateData(["\(postID)" : FieldValue.delete()]) { error in
                    
                    if let error = error {
                        
                        print("error: \(error.localizedDescription)")
                    }else {
                        
                        DispatchQueue.main.async {
                            
                            cell.watchListButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
                            cell.isWatchlistedCheck = false
                            self.decreaseWatchlistedCount(postId: postID, cell: cell)
                        }
                    }
                }
            }
            
        }else if cell.isWatchlistedCheck == false{
                        
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
                            self.increaseWatchlistedCount(postId: postID, cell: cell)
                        }
                    }
                }
            }
            
        }
        
    }
    
    func threeDotMenuButtonDidTap(cell: FeedCell) {
        
        // we getting postId from post
        guard let indexPath = self.tableView.indexPath(for: cell) else {return}
        let post = self.feedViewModel.postList[indexPath.item]
        let postID = post.postId
        
        guard let cuid = Auth.auth().currentUser?.uid as? String else {return}
        
        let username = cell.usernameLabel.text
        
        // compare current userId and post's userId
        
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("users").document(cuid).getDocument { document, error in
            
            if error != nil{
                
                print("\n error: \(String(describing: error?.localizedDescription)) \n")                
            }else {
                
                if let document = document, document.exists {
                    
                    if let curUsername = document.get("username") as? String {
                        
                        if curUsername == username {
                            
                            // forCurrentUser
                            
                            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                            
                            let shareButton = UIAlertAction(title: "share", style: .default)
                            
                            let editButton = UIAlertAction(title: "edit", style: .default) { action in
                                
                                self.performSegue(withIdentifier: "toSaveVCForEdit", sender: postID)
                            }
                            
                            let deleteButton = UIAlertAction(title: "delete", style: .destructive) { action in
                                
                                let alerto = UIAlertController(title: "", message: "are you sure for deleting?", preferredStyle: .alert)
                                
                                let deleteButton = UIAlertAction(title: "yes, delete", style: .destructive) { action in
                                    
                                    let postIdWillDelete = postID
                                    
                                    // firstly, we are deleting post's image from storage (our image id is the same our postId so this makes our process easy)
                                    
                                    let storage = Storage.storage()
                                    let storageReference = storage.reference()
                                    
                                    let imageWillBeDelete = storageReference.child("media").child("\(postIdWillDelete).jpg")
                                    
                                    imageWillBeDelete.delete { error in
                                        
                                        if let error = error {
                                            
                                            print("error: \(error.localizedDescription)")
                                            
                                        }else {
                                            
                                            // secondly, we are deleting post from firestore
                                            
                                            firestoreDb.collection("posts").whereField("postId", isEqualTo: "\(postIdWillDelete)").getDocuments { snapshot, error in
                                                
                                                if error != nil {
                                                    
                                                    self.makeAlert(titleInput: "error", messageInput: "\nyour post couldn't been deleted. please try later.")
                                                    print(error?.localizedDescription ?? "error")
                                                    
                                                }else {
                                                    
                                                    for document in snapshot!.documents {
                                                        
                                                        document.reference.delete()
                                                        
                                                        self.decreasePostCount()
                                                    }
                                                    
                                                    DispatchQueue.main.async {
                                                        self.tableView.reloadData()
                                                    }
                                                    
                                                    self.makeAlert(titleInput: "", messageInput: "\nyour post has been deleted.")
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
                            
                        }else {
                            
                            // forClickedUser
                            
                            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                            
                            let sharebutton = UIAlertAction(title: "share", style: .default)
                            let reportButton =  UIAlertAction(title: "report", style: .default)
                            let blockButton =  UIAlertAction(title: "block user", style: .default) { action in
                                
                                let userWhoSharedPost = post.postedBy
                                
                                print("\n block user clicked: \(userWhoSharedPost)")
                                
                                //addToBlockingList()
                                
                            }
                            let cancelButton =  UIAlertAction(title: "cancel", style: .cancel)
                            
                            alert.addAction(sharebutton)
                            alert.addAction(reportButton)
                            alert.addAction(blockButton)
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
    
    
    func increaseWatchlistedCount(postId : String, cell: FeedCell){
                
         
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("posts").whereField("postId", isEqualTo: postId).getDocuments { querySnapshot, error in
            
            if error != nil{
                
                print("error: \(String(describing: error?.localizedDescription))")
                self.makeAlert(titleInput: "error", messageInput: "\nan error occured. \nplease try again later.")
                
            }else {
                
                DispatchQueue.global().async {
                    
                    for document in querySnapshot!.documents{
                        
                        let documentId = document.documentID
                        
                        if let watchlistedCount = document.get("watchlistedCount") as? Int {
                            
                            // we are setting new postCount
                            let watchlistedCountDic = ["watchlistedCount" : watchlistedCount + 1] as [String : Any]
                            
                            firestoreDb.collection("posts").document(documentId).setData(watchlistedCountDic, merge: true)
                                
                            self.didPullToRefresh()
                            
                            
                        } else {
                            print("\ndocument field was not gotten")
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    func decreaseWatchlistedCount(postId : String, cell: FeedCell){
        
         
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("posts").whereField("postId", isEqualTo: postId).getDocuments { querySnapshot, error in
            
            if error != nil{
                
                print("error: \(String(describing: error?.localizedDescription))")
                self.makeAlert(titleInput: "error", messageInput: "\nan error occured. \nplease try again later.")
                
            }else {
                
                DispatchQueue.global().async {
                    
                    for document in querySnapshot!.documents {
                        
                        let documentId = document.documentID
                        
                        if let watchlistedCount = document.get("watchlistedCount") as? Int {
                            
                            // we are setting new postCount
                            let watchlistedCountDic = ["watchlistedCount" : watchlistedCount - 1] as [String : Any]
                            
                            firestoreDb.collection("posts").document(documentId).setData(watchlistedCountDic, merge: true)
                            
                            self.didPullToRefresh()
                                                                                                                        
                        } else {
                            print("\ndocument field was not gotten")
                        }
                        
                    }
                   
                }
                
            }
            
        }
        
    }
    
    func addToBlockingList(){
        
        
        
    }
    
    func makeAlert (titleInput: String, messageInput: String){
        
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - custom classes


class CustomTapGestureRec: UITapGestureRecognizer {
    
    var username = String()
}
