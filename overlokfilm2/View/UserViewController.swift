//
//  UserViewController.swift
//  overlokfilm2
//
//  Created by hyasar on 7.11.2022.
//

import UIKit
import Firebase
import SDWebImage

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var userFilmsTableView: UITableView!
    
    private var userViewModel : UserViewModel!
    var webService = WebService()
    var userVSM = UserViewSingletonModel.sharedInstance
        
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
        
        getUsername()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        followButton.layer.cornerRadius = 15
        
        profileImage.layer.cornerRadius = profileImage.frame.size.height/2
       
        getData()
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
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toPostDetailVC" {
            
            let destinationVC = segue.destination as! PostDetailViewController
            
            destinationVC.postId = userVSM.postId
            
        }
        
    }
    
    
    func getData(){
        
        webService.downloadDataUserMovies { postList in
            self.userViewModel = UserViewModel(postList: postList)
            
            DispatchQueue.main.async {
                self.userFilmsTableView.reloadData()
            }
            
        }
        
    }
    
    func setFollowButton(){
                
        let cuid = Auth.auth().currentUser?.uid as? String
        
        // get the documentId with this username
        
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("users").whereField("username", isEqualTo: "\(self.usernameLabel.text!)").addSnapshotListener { snapshot, error in
            
            if error != nil{
                print("error caused: " + " \(String(describing: error?.localizedDescription)) ")
            }else{
                
                if snapshot?.isEmpty != true && snapshot != nil {
                        
                        for document in snapshot!.documents{
                            
                            let documentId = document.documentID
                            
                            if documentId == cuid {
                                
                                self.followButton.setTitle("edit profile", for: .normal)
                                //self.followButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
                            }
                        }
                }
                
            }
            
        }
        
    }
    

    @IBAction func logoutClicked(_ sender: Any) {
        
        do{
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "toViewController", sender: nil)
        }catch{
            print("error")
        }
        
    }
    
    @IBAction func userMenuClicked(_ sender: Any) {
    }
    
    
    @IBAction func followButtonClicked(_ sender: Any) {
    }
    
   
    
    func getUsername(){
        
        let cuid = Auth.auth().currentUser?.uid as? String
        
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("users").document(cuid!).getDocument { document, error in
            
            if error != nil{
                self.makeAlert(titleInput: "error", messageInput: error?.localizedDescription ?? "document couldn't be accessed!")
            }else{
                
                if let document = document, document.exists {
                    
                    if let dataDescription = document.get("username") as? String{
                        
                        self.usernameLabel.text = dataDescription
                        self.setFollowButton()
                    } else {
                        print("document field was not gotten")
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
    
}


