//
//  PostDetailViewController.swift
//  overlokfilm2
//
//  Created by hyasar on 7.11.2022.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage
import SDWebImage

final class PostDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DetailCellDelegate {
  
    // MARK: - variables

    @IBOutlet private weak var detailTableView: UITableView!
    
    private var postDetailViewModel : PostDetailVcViewModel!
    private var webService = WebService()
    
    var postId = ""
        
    // MARK: - viewDidLoad and viewWillAppear
    
    override func viewDidLoad() {
        super.viewDidLoad()

        detailTableView.delegate = self
        detailTableView.dataSource = self
                
        //page refresh
        detailTableView.refreshControl = UIRefreshControl()
        detailTableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        getData()
    }
    
    // MARK: - tableView functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.postDetailViewModel == nil ? 0 : self.postDetailViewModel.numberOfRowsInSection()
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = detailTableView.dequeueReusableCell(withIdentifier: "detailOfCell", for: indexPath) as! DetailCell
        cell.likeButton.isEnabled = true
        
        let postViewModel = self.postDetailViewModel.postAtIndex(index: indexPath.row)
                
        cell.postImageView.sd_setImage(with: URL(string: postViewModel.postImageUrl), placeholderImage: UIImage(named: "imagePlaceHolder.png"))
        
        cell.movieNameLabel.text = "\(postViewModel.postMovieName)" + " (\(postViewModel.postMovieYear))"
        cell.directorNameLabel.text = postViewModel.postMovieDirector
        cell.commentLabel.text = postViewModel.postMovieComment
        cell.dateLabel.text = postViewModel.postDate
        cell.usernameLabel.text = postViewModel.postedBy
        cell.userImage.sd_setImage(with: URL(string: postViewModel.userIconUrl))
        cell.watchListCountLabel.text = String(postViewModel.postWatchlistedCount)
        
        
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
        
        
        let gestureRecognizer = CustomTapGestureRecogniz(target: self, action: #selector(userImageTapped))
        let gestureRecognizer2 = CustomTapGestureRecogniz(target: self, action: #selector(usernameLabelTapped))
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
        cell.postId = postViewModel.postId
        
        return cell
        
    }
    
    // MARK: - functions
    
    func getData(){
        
        if postId != "" {
            
            webService.downloadDataDetailPostVC(postID: postId){ postList in
                
                self.postDetailViewModel = PostDetailVcViewModel(postList: postList)
                
                DispatchQueue.main.async {
                    
                    self.detailTableView.reloadData()
                }
                
            }
            
        }else{
            makeAlert(titleInput: "error", messageInput: "\nsorry. post wasn't able to found. please try again later.")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toSaveVCForEditFromPostDetailVC" {
            
            let destinationVC = segue.destination as! SaveViewController
            
            destinationVC.postIdWillEdit = sender as! String
            
        }
        
        if segue.identifier == "toUserVCFromPostDetailVC" {
            
            let destinationVC = segue.destination as! UserViewController
            
            destinationVC.username = sender as! String
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
    
    @objc func userImageTapped(sender: CustomTapGestureRec) {
        
        let username = sender.username
        
        performSegue(withIdentifier: "toUserVCFromPostDetailVC", sender: username)
    }
    
    
    @objc func usernameLabelTapped(sender: CustomTapGestureRec) {
        
        let username = sender.username
        
        performSegue(withIdentifier: "toUserVCFromPostDetailVC", sender: username)
    }
    
    
    func likeButtonDidTap(cell: DetailCell) {
        
        guard let indexPath = detailTableView.indexPath(for: cell) else {return}
        var post = self.postDetailViewModel.postList[indexPath.item]
        let postID = post.postId
        
        guard let cuid = Auth.auth().currentUser?.uid as? String else { return }
                
        if cell.isLikedCheck == true{
            
            // if we liked this post before we can unliked now
            let firestoreDatabase = Firestore.firestore()
            
            DispatchQueue.global().async {
                
                firestoreDatabase.collection("likes").document("\(cuid)").updateData(["\(postID)" : FieldValue.delete()]) { error in
                    
                    if let error = error {
                        
                        print("error: \(error.localizedDescription)")
                        self.makeAlert(titleInput: "error", messageInput: "\nyou unliked this post, however an error occured. \nplease try again later.")
                        
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
                        self.makeAlert(titleInput: "error", messageInput: "\nyou liked this post, however an error occured. \nplease try again later.")
                        
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
    
    func watchListButtonDidTap(cell: DetailCell) {
        
        guard let indexPath = detailTableView.indexPath(for: cell) else {return}
        var post = self.postDetailViewModel.postList[indexPath.item]
        let postID = post.postId
        
        guard let cuid = Auth.auth().currentUser?.uid as? String else { return }
                
        if cell.isWatchlistedCheck == true{
            
            // if we add to watchlist this post before we can unwatchlist now
            let firestoreDatabase = Firestore.firestore()
            
            DispatchQueue.global().async {
                
                firestoreDatabase.collection("watchlists").document("\(cuid)").updateData(["\(postID)" : FieldValue.delete()]) { error in
                    
                    if let error = error {
                        
                        print("error: \(error.localizedDescription)")
                        self.makeAlert(titleInput: "error", messageInput: "\nyou removed this post from watchlist, however an error occured. \nplease try again later.")
                        
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
                        self.makeAlert(titleInput: "error", messageInput: "\nyou added this post to watchlist, however an error occured. \nplease try again later.")
                        
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
    
    
    func threeDotMenuButtonDidTap(cell: DetailCell) {
        
        
        guard let cuid = Auth.auth().currentUser?.uid as? String else {return}
        
        let username = cell.usernameLabel.text
        
        // compare current userId and post's userId
        
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("users").document(cuid).getDocument { document, error in
            
            if error != nil{
                
                print("error: \(String(describing: error?.localizedDescription))")
                self.makeAlert(titleInput: "error", messageInput: "\n\(String(describing: error?.localizedDescription))")
                
            }else {
                
                if let document = document, document.exists {
                    
                    if let curUsername = document.get("username") as? String {
                        
                        if curUsername == username {
                            
                            // forCurrentUser
                            
                            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                            
                            let shareButton = UIAlertAction(title: "share", style: .default)
                            
                            let editButton = UIAlertAction(title: "edit", style: .default) { action in
                                
                                self.performSegue(withIdentifier: "toSaveVCForEditFromPostDetailVC", sender: cell.postId)
                            }
                            
                            let deleteButton = UIAlertAction(title: "delete", style: .destructive) { action in
                                
                                let alerto = UIAlertController(title: "", message: "are you sure for deleting?", preferredStyle: .alert)
                                
                                let deleteButton = UIAlertAction(title: "yes, delete", style: .destructive) { action in
                                    
                                    let postIdWillDelete = cell.postId
                                            
                                            // firstly, we are deleting post's image from storage (our image id is the same our postId so this makes our process easy)
                                            
                                            let storage = Storage.storage()
                                            let storageReference = storage.reference()
                                            
                                            let imageWillBeDelete = storageReference.child("media").child("\(postIdWillDelete).jpg")
                                            
                                            imageWillBeDelete.delete { error in
                                                
                                                if let error = error {
                                                    
                                                    print("error: \(error.localizedDescription)")
                                                    self.makeAlert(titleInput: "error", messageInput: "\nyour post couldn't been deleted. please try later.")
                                                    
                                                }else {
                                                                 
                                                    // secondly, we are deleting post from firestore
                                                    
                                                    firestoreDb.collection("posts").whereField("postId", isEqualTo: "\(postIdWillDelete)").getDocuments { snapshot, error in
                                                        
                                                        if error != nil {
                                                            
                                                            print(error?.localizedDescription ?? "error")
                                                            self.makeAlert(titleInput: "error", messageInput: "\nyour post couldn't been deleted. please try later.")
                                                            
                                                        }else {
                                                            
                                                            for document in snapshot!.documents {
                                                                
                                                                document.reference.delete()
                                                                self.decreasePostCount()
                                                                self.tabBarController?.selectedIndex = 0
                                                                self.navigationController?.popViewController(animated: true)
                                                            }
                                                    
                                                    DispatchQueue.main.async {
                                                        
                                                        self.detailTableView.reloadData()
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
                            
                            // for clicked user
                            
                            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                            
                            let sharebutton = UIAlertAction(title: "share", style: .default)
                            let reportButton =  UIAlertAction(title: "report", style: .default)
                            let blockButton =  UIAlertAction(title: "block user", style: .default)
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
    
    
    
    func increaseWatchlistedCount(postId : String, cell: DetailCell){
                
        // getDocuments ile cekiyoruz
         
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("posts").whereField("postId", isEqualTo: postId).getDocuments { querySnapshot, error in
            
            if error != nil{
                
                print("error: \(String(describing: error?.localizedDescription))")
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
    
    func decreaseWatchlistedCount(postId : String, cell: DetailCell){
        
        // getDocuments ile cekiyoruz
         
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("posts").whereField("postId", isEqualTo: postId).getDocuments { querySnapshot, error in
            
            if error != nil{
                
                print("error: \(String(describing: error?.localizedDescription))")
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
    
    @objc private func didPullToRefresh(){
        
        getData()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            
            self.detailTableView.refreshControl?.endRefreshing()
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

// MARK: - custom classes

class CustomTapGestureRecogniz: UITapGestureRecognizer {
    
    var username = String()
}
