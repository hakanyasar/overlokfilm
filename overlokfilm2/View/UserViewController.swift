//
//  UserViewController.swift
//  overlokfilm2
//
//  Created by hyasar on 7.11.2022.
//

import Foundation
import UIKit
import Firebase
import SDWebImage

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var userFilmsTableView: UITableView!
    
    private var userViewModel : UserViewModel!
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
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
                
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
        
    }
    
    
    func getData(uName : String){
        
        webService.downloadDataUserVC (uName: uName) { postList in
            self.userViewModel = UserViewModel(postList: postList)
            
            DispatchQueue.main.async {
                
                self.userFilmsTableView.reloadData()
            }
            
        }
        
    }
    
    @objc func chooseProfileImage(){
        
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
                        
                        firestoreDatabase.collection("posts").whereField("postedBy", isEqualTo: "\(curUsername)").getDocuments { snapshot, error in
                            
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
        
        // if we have not followed yet, we can follow her/him in here
        
        if self.followButton.titleLabel?.text == "follow" {
            
            guard let cuid = Auth.auth().currentUser?.uid as? String else { return }
            
            getClickedUserId { clickedUserId in
                
                let firestoreDatabase = Firestore.firestore()
                
                let ref = firestoreDatabase.collection("following").document(cuid)
                
                let values = [clickedUserId: 1]
                
                ref.setData(values, merge: true) { error in
                    
                    if error != nil {
                        
                        print(error?.localizedDescription ?? "error")
                        
                    }else {
                        
                        self.followButton.setTitle("unfollow", for: .normal)
                        self.followButton.backgroundColor = .systemBackground
                        
                        
                        
                    }
                    
                }
                
            }
            
        }else {
            
            // if we already have followed clickedUser, we can unfollow her/him here
            
            if self.followButton.titleLabel?.text == "unfollow" &&  self.followButton.titleLabel?.text != "edit profile" {
                                                
                guard let cuid = Auth.auth().currentUser?.uid as? String else { return }
                
                self.getClickedUserId { clickedUserId in
                    
                    let firestoreDatabase = Firestore.firestore()
                    
                    firestoreDatabase.collection("following").document("\(cuid)").updateData(["\(clickedUserId)" : FieldValue.delete()]) { error in
                        
                        if let error = error {
                            
                            print("error: \(error.localizedDescription)")
                            
                        }else {
                            
                            self.followButton.setTitle("follow", for: .normal)
                            self.followButton.backgroundColor = .systemGray5
                            
                        }
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    
    
    func setAllPageDatas(){
        
        self.setProfileImage()
        self.setBio()
        
        if self.username == "" {
            
            getCurrentUsername { curUsername in
                
                self.usernameLabel.text = curUsername
                self.followButton.setTitle("edit profile", for: .normal)
                
                self.getData(uName: self.usernameLabel.text!)
            }
            
        }else {
            
            getCurrentUsername { curName in
                
                if curName == self.username {
                    
                    self.usernameLabel.text = self.username
                    self.followButton.setTitle("edit profile", for: .normal)
                    
                    self.getData(uName: self.usernameLabel.text!)
                   
                } else {
                                        
                    
                    self.usernameLabel.text = self.username
                    self.followButton.setTitle("follow", for: .normal)
                    
                    self.getData(uName: self.usernameLabel.text!)
                    
                    
                    // we are looking for whether current user follows the clickedUser if yes our button should show "unfollow" if no it should show "follow"
                    
                    guard let cuid = Auth.auth().currentUser?.uid as? String else { return }
                    
                    self.getClickedUserId { clickedUserId in
                        
                        
                        let firestoreDatabase = Firestore.firestore()
                        
                        firestoreDatabase.collection("following").whereField("\(clickedUserId)", isEqualTo: 1).addSnapshotListener { snapshot, error in
                            
                            if error != nil {
                                
                                print(error?.localizedDescription ?? "error")
                                
                            }else {
                                
                                if snapshot?.isEmpty != true && snapshot != nil {
                                    
                                    DispatchQueue.global().async {
                                        
                                        for document in snapshot!.documents {
                                            
                                            if document.exists && document.documentID == cuid {
                                                
                                                DispatchQueue.main.async {
                                                    
                                                    self.usernameLabel.text = self.username
                                                    self.followButton.setTitle("unfollow", for: .normal)
                                                    
                                                    
                                                    self.followButton.backgroundColor = .systemBackground
                                                    self.followButton.layer.cornerRadius = 15
                                                    self.followButton.layer.borderColor = UIColor.gray.cgColor
                                                    self.followButton.layer.borderWidth = 1
                                                     
                                                    self.getData(uName: self.usernameLabel.text!)
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }else {
                                    
                                    print("snapshot is empty or nil: \(String(describing: error))")
                                    
                                }
                                
                            }
                            
                        }
                     
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    func setBio() {
        
        
    }
    
    
    func setProfileImage() {
        
        
        if self.username == "" {
            
            let cuid = Auth.auth().currentUser?.uid as? String
            
            let firestoreDb = Firestore.firestore()
            
            firestoreDb.collection("users").document(cuid!).getDocument { document, error in
                
                if error != nil{
                    print(error?.localizedDescription ?? "error")
                }else{
                    
                    if let document = document, document.exists {
                        
                        if let dataDescription = document.get("profileImageUrl") as? String{
                            
                            let imageUrl = dataDescription
                            self.profileImage.sd_setImage(with: URL(string: imageUrl))
                            
                        } else {
                            print("document field was not gotten")
                        }
                        
                    }
                    
                }
                
            }
            
        }else {
            
            let firestoreDb = Firestore.firestore()
            
            let clickedUser = self.username
            
            firestoreDb.collection("users").whereField("username", isEqualTo: "\(clickedUser)").getDocuments { snapshot, error in
                
                if error != nil {
                    
                    print(error?.localizedDescription ?? "error")
                }else {
                    
                    for document in snapshot!.documents {
                        
                        let clickedUserId = document.documentID
                                                
                        firestoreDb.collection("users").document(clickedUserId).getDocument { document, error in
                            
                            if error != nil{
                                
                                print(error?.localizedDescription ?? "error")
                            }else {
                                
                                if let document = document, document.exists {
                                    
                                    if let dataDescription = document.get("profileImageUrl") as? String{
                                        
                                        let imageUrl = dataDescription
                                        self.profileImage.sd_setImage(with: URL(string: imageUrl))
                                        
                                    } else {
                                        print("document field was not gotten")
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                }
                
            }
            
        }
        
    }
    
    func updateProfileImageOnDB() {
        
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
                                
                                firestoreDatabase.collection("posts").whereField("postedBy", isEqualTo: "\(curUsername)").getDocuments { snapshot, error in
                                    
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
    
    
    func makeAlert(titleInput: String, messageInput: String){
        
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func setAppearance() {
    
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
        
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("users").whereField("username", isEqualTo: "\(self.username)").getDocuments { snapshot, error in
            
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
        
        guard let cuid = Auth.auth().currentUser?.uid as? String else { return }
        
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("users").document(cuid).getDocument { document, error in
            
            if error != nil{
                
                self.makeAlert(titleInput: "error", messageInput: error?.localizedDescription ?? "\ndocument couldn't be accessed!")
                self.usernameLabel.text = "overlokcu"
                
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
        
        let likesButton = UIAlertAction(title: "likes", style: .default)
        let watchlistButton = UIAlertAction(title: "watchlist", style: .default)
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
        
        let likesButton = UIAlertAction(title: "likes", style: .default)
        let watchlistButton =  UIAlertAction(title: "watchlist", style: .default)
        let cancelButton = UIAlertAction(title: "cancel", style: .cancel)
        
        alert.addAction(likesButton)
        alert.addAction(watchlistButton)
        alert.addAction(cancelButton)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
}





