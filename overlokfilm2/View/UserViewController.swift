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
        
        // in here, we activate clickable feature on image
        profileImage.isUserInteractionEnabled = true
        
        // and here, we describe gesture recognizer for upload with click on image
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseProfileImage))
        profileImage.addGestureRecognizer(gestureRecognizer)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setAllPageDatas()
        setAppearance()
        
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
        
        webService.downloadDataUserMovies (uName: uName) { postList in
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
            
            var firestoreListener : ListenerRegistration?
            firestoreListener?.remove()
            
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
    }
    
    
    
    func setAllPageDatas(){
        
        
        if self.username == "" {
            
            
            getCurrentUsername { usName in
                
                self.usernameLabel.text = usName
                self.followButton.setTitle("edit profile", for: .normal)
                
                self.getData(uName: self.usernameLabel.text!)
                self.setProfileImage()
            }
            
        }else {
            
            getCurrentUsername { usName in
                
                if usName == self.username {
                    
                    self.usernameLabel.text = self.username
                    self.followButton.setTitle("edit profile", for: .normal)
                    
                    self.getData(uName: self.usernameLabel.text!)
                    self.setProfileImage()
                    
                } else {
                    
                    self.usernameLabel.text = self.username
                    self.followButton.setTitle("follow", for: .normal)
                    
                    self.getData(uName: self.usernameLabel.text!)
                    
                }
                
            }
            
        }
        
    }
    
    
    
    
    func setProfileImage() {
        
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
        
        followButton.layer.cornerRadius = 15
        
        profileImage.contentMode = .scaleAspectFill
        profileImage.clipsToBounds = true  // what does this do?
        
        profileImage.layer.cornerRadius = profileImage.frame.size.height/2
        profileImage.layer.masksToBounds = true
        profileImage.layer.borderColor = UIColor.gray.cgColor
        profileImage.layer.borderWidth = 1
        
    }
    
    
    func getCurrentUsername(complation: @escaping (String) -> Void) {
        
        let cuid = Auth.auth().currentUser?.uid as? String
        
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("users").document(cuid!).getDocument { document, error in
            
            if error != nil{
                self.makeAlert(titleInput: "error", messageInput: error?.localizedDescription ?? "document couldn't be accessed!")
                self.usernameLabel.text = "overlokcu"
            }else{
                
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
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        alert.addAction(UIAlertAction(title: "likes", style: .default, handler: { action in
            
            
            
        }))
        
        
        alert.addAction(UIAlertAction(title: "watchlist", style: .default, handler: { action in
            
        }))
        
        
        alert.addAction(UIAlertAction(title: "services", style: .default, handler: { action in
            
            let alertSer = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            alertSer.addAction(UIAlertAction(title: "contact us", style: .default, handler: { action in
                
                
            }))
            
            alertSer.addAction(UIAlertAction(title: "privacy", style: .default, handler: { action in
                
                
            }))
            
            alertSer.addAction(UIAlertAction(title: "about us", style: .default, handler: { action in
                
                
            }))
            
            alertSer.addAction(UIAlertAction(title: "delete account", style: .destructive, handler: { action in
                
                
            }))
            
            alertSer.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: { _ in
                
            }))
            
            DispatchQueue.main.async {
                
                self.present(alertSer, animated: true, completion: nil)
            }
        }))
        
        
        alert.addAction(UIAlertAction(title: "log out", style: .destructive, handler: { action in
            
            let alertIn = UIAlertController(title: "", message: "log out of your account?", preferredStyle: .alert)
            
            alertIn.addAction(UIAlertAction(title: "logout", style: .destructive, handler: { _ in
                
                do{
                    try Auth.auth().signOut()
                    self.performSegue(withIdentifier: "toViewController", sender: nil)
                }catch{
                    print("error")
                }
                
            }))
            
            alertIn.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: { _ in
                
            }))
            
            DispatchQueue.main.async {
                
                self.present(alertIn, animated: true, completion: nil)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
}





