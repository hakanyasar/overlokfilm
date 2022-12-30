//
//  UserViewController.swift
//  overlokfilm2
//
//  Created by hyasar on 7.11.2022.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage
import SDWebImage

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var userFilmsTableView: UITableView!
    
    private var userViewModel : UserVcViewModel!
    private var justUserViewModel : JustUserViewModel!
    var webService = WebService()
    var userVSM = UserViewSingletonModel.sharedInstance
    
    var username = ""
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                        
        print("\n viewDidLoad un icindeyiz \n")
        
        userFilmsTableView.delegate = self
        userFilmsTableView.dataSource = self
        
        getCurrentUsername { curName in
            
            if self.username == curName {
                
                // in here, we activate clickable feature on image
                self.profileImage.isUserInteractionEnabled = true
            }
            
        }
        
        // and here, we describe gesture recognizer for upload with click on image
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseProfileImage))
        profileImage.addGestureRecognizer(gestureRecognizer)
        
        //data refresh
        userFilmsTableView.refreshControl = UIRefreshControl()
        userFilmsTableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
                
        print("\n viewWillAppear ın icindeyiz \n")
        
        setAllPageDatas()
        setAppearance()
        
        getCurrentUsername { curName in
            
            if curName == self.usernameLabel.text {
                
                // in here, we activate clickable feature on image
                self.profileImage.isUserInteractionEnabled = true
                
            }
        }
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.userViewModel == nil ? 0 : self.userViewModel.numberOfRowsInSection()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = userFilmsTableView.dequeueReusableCell(withIdentifier: "cellOfUserView", for: indexPath) as! UserFeedCell
        
        let postViewModel = self.userViewModel.postAtIndex(index: indexPath.row)
        
        cell.filmLabel.text = "\(indexPath.row + 1) - " + "\(postViewModel.postMovieName)" + " (\(postViewModel.postMovieYear))"
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let postViewModel = self.userViewModel.postAtIndex(index: indexPath.row)
        
        userVSM = UserViewSingletonModel.sharedInstance
        
        userVSM.postId = postViewModel.postId
        
        performSegue(withIdentifier: "toPostDetailVC", sender: indexPath)
        
        // this command prevent gray colour when come back after selection
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toPostDetailVC" {
            
            let destinationVC = segue.destination as! PostDetailViewController
            
            destinationVC.postId = userVSM.postId
            
        }
        
        if segue.identifier == "toLikesVC" {
            
            let destinationVC = segue.destination as! LikesViewController
            
            destinationVC.username = self.usernameLabel.text!
        }
        
        if segue.identifier == "toWatchlistsVC" {
            
            let destinationVC = segue.destination as! WatchlistsViewController
            
            destinationVC.username = self.usernameLabel.text!
        }
        
    }
    
    
    func getData(uName : String){

        print("\n getData nın icindeyiz \n")
        
        webService.downloadDataUserVC (uName: uName) { postList in
            
            self.userViewModel = UserVcViewModel(postList: postList)
    
            DispatchQueue.main.async {
                
                self.userFilmsTableView.reloadData()
            }
        }
        
    }
    
    func getUserFields(uName: String){
        
        print("\n getUserFields ın icindeyiz \n")
                
        webService.downloadDataForUserFields(username: uName) { user in
            
            self.justUserViewModel = JustUserViewModel(user: user)
                        
            //DispatchQueue.main.async {
                
                print("\n get fields dispatchqueu dayız \n")
                
                self.setProfileImage(userJVM: self.justUserViewModel)
                self.setBio(userJVM: self.justUserViewModel)
                self.setCounts(userJVM: self.justUserViewModel)
            //}
            
        }
        
    }
    
    @objc func chooseProfileImage(){
        
        print("\n chooseProfileImage ın icindeyiz \n")
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        alert.addAction(UIAlertAction(title: "change", style: .default, handler: { action in
            
            // we describe picker controller stuff for reach to user gallery
            let pickerController = UIImagePickerController()
            // we assign self to picker controller delegate so we can call some methods that we will use
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
            
        }))
        
        
        alert.addAction(UIAlertAction(title: "delete", style: .destructive, handler: { action in
            
            //var firestoreListener : ListenerRegistration?
            //firestoreListener?.remove()
            
            // storage
            
            let storage = Storage.storage()
            let storageReference = storage.reference()
            let imageData = storageReference.child("userDefaultProfileImage/userDefaultImage.png")
            
            imageData.downloadURL { url, error in
                
                if error == nil {
                    
                    let imageUrl = url?.absoluteString
                                        
                    self.profileImage.sd_setImage(with: URL(string: "\(imageUrl!)"))
                    
                    
                    // delete from database (actually we changing with default image)
                    
                    let cuid = Auth.auth().currentUser?.uid as? String
                    
                    let firestoreDatabase = Firestore.firestore()
                    
                    firestoreDatabase.collection("users").document(cuid!).setData(["profileImageUrl" : imageUrl!], merge: true)
                    
                    
                    // to update old post's profile images
                    
                    self.getCurrentUsername { curUsername in
                        
                        firestoreDatabase.collection("posts").whereField("postedBy", isEqualTo: "\(curUsername)").getDocuments(source: .server) { snapshot, error in
                            
                            if error != nil {
                                
                                print(error?.localizedDescription ?? "error")
                            }else {
                                
                                for document in snapshot!.documents {
                                    
                                    document.reference.updateData(["userIconUrl" : "\(imageUrl!)"])
                                    
                                }
                                
                            }
                            
                        }
                        self.makeAlert(titleInput: "", messageInput: "\nyour profile image has been deleted.")
                    }
                    
                    
                }
                
            }
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: { action in }))
        
        DispatchQueue.main.async {
            
            self.present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    // here is about what is gonna happen after choose image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        profileImage.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        // update profile image on storage and database
        updateProfileImageOnDB()
        
    }
    
    
    
    
    @IBAction func followButtonClicked(_ sender: Any) {
        
        print("\n ______________---------------________________ \n")
        print("\n followButtonClicked in icindeyiz \n")
        print("\n ______________---------------________________ \n")
        
        // if we have not followed yet, we can follow her/him in here
        
        if self.followButton.titleLabel?.text == "follow" {
                        
            guard let cuid = Auth.auth().currentUser?.uid as? String else { return }
            
            getClickedUserId { clickedUserId in
                
                let firestoreDatabase = Firestore.firestore()
                
                let ref = firestoreDatabase.collection("following").document(cuid)
                
                let values = [clickedUserId: 1]
                
                DispatchQueue.global().async {
                    
                    ref.setData(values, merge: true) { error in
                        
                        if error != nil {
                            
                            print(error?.localizedDescription ?? "error")
                            
                        }else {
                            
                            DispatchQueue.main.async {
                                
                                self.increaseFollowersCountClickedUser()
                                self.increaseFollowingCountCurUser()
                                
                                self.followButton.setTitle("unfollow", for: .normal)
                                self.followButton.backgroundColor = .systemBackground
                                
                                self.setFollowCounts(user: self.justUserViewModel)
                                //self.makeAlert(titleInput: "", messageInput: "you followed \(self.username)")
                            }
                            
                        }
                        
                    }
                }
                
            }
            
        }else {
            
            // if we already have followed clickedUser, we can unfollow her/him here
            
            if self.followButton.titleLabel?.text == "unfollow" &&  self.followButton.titleLabel?.text != "edit profile" {
                
                guard let cuid = Auth.auth().currentUser?.uid as? String else { return }
                
                self.getClickedUserId { clickedUserId in
                    
                    let firestoreDatabase = Firestore.firestore()
                                            
                    DispatchQueue.global().async {
                        
                        firestoreDatabase.collection("following").document("\(cuid)").updateData(["\(clickedUserId)" : FieldValue.delete()]) { error in
                            
                            if let error = error {
                                
                                print("error: \(error.localizedDescription)")
                                
                            }else {
                              
                                DispatchQueue.main.async {
                                    
                                    self.decreaseFollowersCountClickedUser()
                                    self.decreaseFollowingCountCurUser()
                                    
                                    self.followButton.setTitle("follow", for: .normal)
                                    self.followButton.backgroundColor = .systemGray5
                                    
                                    self.setFollowCounts(user: self.justUserViewModel)
                                    //self.makeAlert(titleInput: "", messageInput: "you unfollowed \(self.username)")
                                }
                                
                            }
                        }
                    }
                                        
                }
                
            }else if self.followButton.titleLabel?.text == "edit profile" {
                
                performSegue(withIdentifier: "toEditBioVC", sender: nil)
                
                
            }
            
        }
        
    }
    
    func increaseFollowingCountCurUser() {
            
        print(" \n we are in increaseFollowingCountCurUser \n ")
        
        
            guard let cuid = Auth.auth().currentUser?.uid as? String else {return}
            
            let firestoreDb = Firestore.firestore()
            
            firestoreDb.collection("users").document(cuid).getDocument(source: .server) { document, error in
                
                if error != nil{
                    
                    print("error: \(String(describing: error?.localizedDescription))")
                    
                }else {
                    
                    if let document = document, document.exists {
                        
                        DispatchQueue.global().async {
                            
                            if let followingCount = document.get("followingCount") as? Int {
                                            
                                // we are setting new postCount
                                let followingCountDic = ["followingCount" : followingCount + 1] as [String : Any]
                                
                                firestoreDb.collection("users").document(cuid).setData(followingCountDic, merge: true)
                                
                            } else {
                                print("document field was not gotten")
                            }
                        }
                        
                    }
                    
                }
                
            }
        
    }
    
    func increaseFollowersCountClickedUser(){
        
        print(" \n we are in increaseFollowersCountClickedUser \n ")
        
        
        getClickedUserId { clickedUserId in
                        
            let firestoreDb = Firestore.firestore()
            
            firestoreDb.collection("users").document(clickedUserId).getDocument(source: .server) { document, error in
                
                if error != nil{
                    
                    print("error: \(String(describing: error?.localizedDescription))")
                    
                }else {
                    
                    if let document = document, document.exists {
                        
                        DispatchQueue.global().async {
                            
                            if let followersCount = document.get("followersCount") as? Int {
                                            
                                // we are setting new postCount
                                let followersCountDic = ["followersCount" : followersCount + 1] as [String : Any]
                                
                                firestoreDb.collection("users").document(clickedUserId).setData(followersCountDic, merge: true)
                                
                            } else {
                                print("document field was not gotten")
                            }
                        }
                      
                    }
                    
                }
                
            }
            
            
        }
        
        
    }
    
    func decreaseFollowingCountCurUser(){
        
        print(" \n we are in decreaseFollowingCountCurUser \n ")
        

        guard let cuid = Auth.auth().currentUser?.uid as? String else {return}
        
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("users").document(cuid).getDocument(source: .server) { document, error in
            
            if error != nil{
                
                print("error: \(String(describing: error?.localizedDescription))")
                
            }else {
                
                if let document = document, document.exists {
                    
                    DispatchQueue.global().async {
                        
                        if let followingCount = document.get("followingCount") as? Int {
                                        
                            // we are setting new postCount
                            let followingCountDic = ["followingCount" : followingCount - 1] as [String : Any]
                            
                            firestoreDb.collection("users").document(cuid).setData(followingCountDic, merge: true)
                            
                        } else {
                            print("document field was not gotten")
                        }
                    }
                   
                }
                
            }
            
        }
        
    }
    
    func decreaseFollowersCountClickedUser(){
        
        print(" \n we are in decreaseFollowersCountClickedUser \n ")
      
        getClickedUserId { clickedUserId in
                        
            let firestoreDb = Firestore.firestore()
            
            firestoreDb.collection("users").document(clickedUserId).getDocument(source: .server) { document, error in
                
                if error != nil{
                    
                    print("error: \(String(describing: error?.localizedDescription))")
                    
                }else {
                    
                    if let document = document, document.exists {
                        
                        DispatchQueue.global().async {
                            
                            if let followersCount = document.get("followersCount") as? Int {
                                            
                                // we are setting new postCount
                                let followersCountDic = ["followersCount" : followersCount - 1] as [String : Any]
                                
                                firestoreDb.collection("users").document(clickedUserId).setData(followersCountDic, merge: true)
                                
                            } else {
                                print("document field was not gotten")
                            }
                        }
                        
                    }
                    
                }
                
            }
            
            
        }
        
    }
    
    
    
    func setAllPageDatas(){
        
        print("\n ----- setAllPagesData nın icindeyiz ----- \n")
        
        if self.username == "" {
            
            print("\n case_1: self.username bos  \n")
            
            getCurrentUsername { curUsername in
                    
                self.usernameLabel.text = curUsername
                self.followButton.setTitle("edit profile", for: .normal)
                
                self.getData(uName: self.usernameLabel.text!)
                self.getUserFields(uName: self.usernameLabel.text!)
                
            }
            
        }else {
            
            getCurrentUsername { curName in
                
                if curName == self.username {
                    
                    print("\n case_2: username ile curUser ayni \n")
                    
                    self.usernameLabel.text = self.username
                    self.followButton.setTitle("edit profile", for: .normal)
                    
                    self.getData(uName: self.usernameLabel.text!)
                    self.getUserFields(uName: self.usernameLabel.text!)
                   
                } else {
                    
                    print("\n case_3: farkli birinin profiline girdik  \n")
                 
                    self.usernameLabel.text = self.username
                    self.followButton.setTitle("follow", for: .normal)
                    
                    self.getData(uName: self.usernameLabel.text!)
                    self.getUserFields(uName: self.usernameLabel.text!)
                    
                    
                    // we are looking for whether current user follows the clickedUser if yes our button should show "unfollow" if no it should show "follow"
                    
                    guard let cuid = Auth.auth().currentUser?.uid as? String else { return }
                    
                    self.getClickedUserId { clickedUserId in
                        
                    let firestoreDatabase = Firestore.firestore()
                        
                        
                        firestoreDatabase.collection("following").document(cuid).getDocument(source: .server) { document, error in
                            
                            print("following e girdik")
                            
                            if error != nil {
                                
                                print(error?.localizedDescription ?? "error")
                                
                            }else {
                                
                                if let document = document, document.exists {
                                                             
                                    print("dokumana girdik")
                                    if let data = document.get("\(clickedUserId)") as? Int {
                                        
                                        print(" \n data: \(data)")
                                        
                                        DispatchQueue.main.async {
                                            
                                            print("dispatchquueu ya girdik")
                                            self.usernameLabel.text = self.username
                                            self.followButton.setTitle("unfollow", for: .normal)
                                            
                                            self.followButton.backgroundColor = .systemBackground
                                            self.followButton.layer.cornerRadius = 15
                                            self.followButton.layer.borderColor = UIColor.gray.cgColor
                                            self.followButton.layer.borderWidth = 1
                                             
                                            self.getData(uName: self.usernameLabel.text!)
                                            self.getUserFields(uName: self.usernameLabel.text!)
                                            
                                        }
                                        
                                    }else{
                                        print("there is no field like this in following.")
                                    }
                                    
                                }else {
                                    print("document doesn't exist in following.")
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
           
                }
                
            }
            
        }
        
    }
    
    
    func setBio(userJVM: JustUserViewModel) {
        
        print("\n setBio nun icindeyiz \n")
        
        DispatchQueue.main.async {
            
            self.bioLabel.text = userJVM.user.bio
        }
        
        
    }
    
    func setCounts(userJVM: JustUserViewModel) {
        
        print("\n setCounts un icindeyiz \n")
        
        DispatchQueue.main.async {
            
            self.postsLabel.text = "\(userJVM.user.postCount)"
            self.followersLabel.text = "\(userJVM.user.followersCount)"
            self.followingLabel.text = "\(userJVM.user.followingCount)"
        }
        
    }
    
    
    func setFollowCounts(user: JustUserViewModel){
        
        print("\n setFollowCounts un icindeyiz \n ")
        
        DispatchQueue.main.async {
            
            self.followersLabel.text = "\(user.user.followersCount)"
            self.followingLabel.text = "\(user.user.followingCount)"
        }
        
    }
    
    func setProfileImage(userJVM: JustUserViewModel) {
        
        print("\n setProfileImage ın icindeyiz \n")
        
        DispatchQueue.main.async {
            
            self.profileImage.sd_setImage(with: URL(string: userJVM.user.profileImageUrl))
        }
        
    }
    
    func updateProfileImageOnDB() {
        
        print("updateProfileImage ın icindeyiz")
        
        var firestoreListener : ListenerRegistration?
        firestoreListener?.remove()
        
        // storage
        
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let userPPMediaFolder = storageReference.child("userProfileImages")
        
        
        if let data = profileImage.image?.jpegData(compressionQuality: 0.5) {
            
            // now we can save this data to storage
            
            let uuid = UUID().uuidString
            
            let imageReference = userPPMediaFolder.child("\(uuid).jpg")
            
            imageReference.putData(data, metadata: nil) { metadata, error in
                
                if error != nil{
                    self.makeAlert(titleInput: "error", messageInput: error?.localizedDescription ?? "error")
                }else {
                    
                    imageReference.downloadURL { url, error in
                        
                        if error == nil {
                            
                            let imageUrl = url?.absoluteString
                            
                            // database
                            
                            let cuid = Auth.auth().currentUser?.uid as? String
                            
                            let firestoreDatabase = Firestore.firestore()
                            
                            firestoreDatabase.collection("users").document(cuid!).setData(["profileImageUrl" : imageUrl!], merge: true)
                            
                            // to update old post's profile images
                     
                            self.getCurrentUsername { curUsername in
                                
                                firestoreDatabase.collection("posts").whereField("postedBy", isEqualTo: "\(curUsername)").getDocuments(source: .server) { snapshot, error in
                                    
                                    if error != nil {
                                        
                                        print(error?.localizedDescription ?? "error")
                                    }else {
                                        
                                        for document in snapshot!.documents {
                                            
                                            document.reference.updateData(["userIconUrl" : "\(imageUrl!)"])
                                        }
                                        
                                    }
                                    
                                }
                                self.makeAlert(titleInput: "", messageInput: "\nyour profile image has been changed.")
                            }
                            
                            
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    @objc private func didPullToRefresh(){
        
        getData(uName: self.username)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            
            self.userFilmsTableView.refreshControl?.endRefreshing()
        }
    }
    
    
    func makeAlert(titleInput: String, messageInput: String){
        
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func setAppearance() {
    
        print("\n setAppearance in icindeyiz \n")
        
        followButton.layer.masksToBounds = true
        followButton.backgroundColor = .systemGray5
        followButton.layer.cornerRadius = 15
        followButton.layer.borderColor = UIColor.gray.cgColor
        followButton.layer.borderWidth = 1
        
        profileImage.contentMode = .scaleAspectFill
        profileImage.clipsToBounds = true  // what does this do?
        
        profileImage.layer.cornerRadius = profileImage.frame.size.height/2
        profileImage.layer.masksToBounds = true
        profileImage.layer.borderColor = UIColor.gray.cgColor
        profileImage.layer.borderWidth = 1
        
    }
    
    func getClickedUserId(completion: @escaping (String) -> Void) {
        
        print("\n getClickedUsername in icindeyiz \n")
        
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("users").whereField("username", isEqualTo: "\(self.username)").getDocuments(source: .server) { snapshot, error in
            
            if error != nil {
                
                print(error?.localizedDescription ?? "error")
            }else {
                                    
                DispatchQueue.global().async {
                    
                    for document in snapshot!.documents {
                            
                            let clickedUserId = document.documentID
                            completion(clickedUserId)
                        
                    }
                    
                }
                      
            }
            
        }
        
    }
    
    
    func getCurrentUsername(complation: @escaping (String) -> Void) {
        
        print("\n getCurrentUsername in icindeyiz \n")
        
        guard let cuid = Auth.auth().currentUser?.uid as? String else { return }
        
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("users").document(cuid).getDocument(source: .server) { document, error in
            
            if error != nil{
                
                //self.makeAlert(titleInput: "error", messageInput: error?.localizedDescription ?? "\ndocument couldn't be accessed!")
                self.usernameLabel.text = "overlokcu"
                self.makeAlert(titleInput: "error", messageInput: "\n page couldn't load. try againlater .")
                
            }else {
                
                if let document = document, document.exists {
                                            
                        if let dataDescription = document.get("username") as? String{
                            
                            complation(dataDescription)
                            
                        } else {
                            print("document field was not gotten")
                        }
                    
                }
                
            }
            
        }
        
    }
    
    
    
    
    @IBAction func userMenuClicked(_ sender: Any) {
        
        if self.username == "" {
            
            self.showNormalUserMenu()
            
        }else {
            
            getCurrentUsername { curName in
                
                if self.username == curName {
                    
                    self.showNormalUserMenu()
                }else{
                    
                    self.showClickedUserMenu()
                    
                }
                
            }
            
        }
        
    }
    
    
    func showNormalUserMenu() {
        
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let likesButton = UIAlertAction(title: "likes", style: .default){ action  in
                        
            self.performSegue(withIdentifier: "toLikesVC", sender: nil)
        }
        let watchlistButton = UIAlertAction(title: "watchlist", style: .default){ action in
            
            self.performSegue(withIdentifier: "toWatchlistsVC", sender: nil)
        }
        let servicesButton = UIAlertAction(title: "services", style: .default) { action in
            
            let alertSer = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let contactUsButton = UIAlertAction(title: "contact us", style: .default)
            let privacyButton = UIAlertAction(title: "privacy", style: .default)
            let aboutUsButton = UIAlertAction(title: "about us", style: .default)
            let deleteAccountButton = UIAlertAction(title: "delete account", style: .destructive)
            let cancelButton = UIAlertAction(title: "cancel", style: .cancel)
            
            alertSer.addAction(contactUsButton)
            alertSer.addAction(privacyButton)
            alertSer.addAction(aboutUsButton)
            alertSer.addAction(deleteAccountButton)
            alertSer.addAction(cancelButton)
            
            DispatchQueue.main.async {
                self.present(alertSer, animated: true, completion: nil)
            }
        }
        
        let logoutButton = UIAlertAction(title: "logout", style: .destructive) { action in
            
            let alerto = UIAlertController(title: "", message: "log out of your account?", preferredStyle: .alert)
            
            let logoutButton = UIAlertAction(title: "yes, logout", style: .destructive) { action in
                
                do{
                    try Auth.auth().signOut()
                    self.performSegue(withIdentifier: "toViewController", sender: nil)
                }catch{
                    print("error")
                }
                
                
            }
            let cancelButton = UIAlertAction(title: "cancel", style: .cancel)
            
            alerto.addAction(logoutButton)
            alerto.addAction(cancelButton)
            
            DispatchQueue.main.async {
                self.present(alerto, animated: true, completion: nil)
            }
            
        }
        let cancelButton = UIAlertAction(title: "cancel", style: .cancel)
        
        alert.addAction(likesButton)
        alert.addAction(watchlistButton)
        alert.addAction(servicesButton)
        alert.addAction(logoutButton)
        alert.addAction(cancelButton)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    func showClickedUserMenu() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let likesButton = UIAlertAction(title: "likes", style: .default){ action in
            
            self.performSegue(withIdentifier: "toLikesVC", sender: nil)
        }
        let watchlistButton =  UIAlertAction(title: "watchlist", style: .default){ action in
            
            self.performSegue(withIdentifier: "toWatchlistsVC", sender: nil)
        }
        let cancelButton = UIAlertAction(title: "cancel", style: .cancel)
        
        alert.addAction(likesButton)
        alert.addAction(watchlistButton)
        alert.addAction(cancelButton)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
}





