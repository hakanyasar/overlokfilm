//
//  UserViewController.swift
//  overlokfilm2
//
//  Created by hyasar on 7.11.2022.
//

import UIKit
import Firebase

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var userFilmsTableView: UITableView!
    
    private var userViewModel : UserViewModel!
    var webService = WebService()
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userFilmsTableView.delegate = self
        userFilmsTableView.dataSource = self
        
        getUsername()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        followButton.layer.cornerRadius = 15
        profileImage.layer.cornerRadius = 50
        
        
        //profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        
        getData()
        
        
    }
    
    
    func getData(){
        webService.downloadDataUserMovies { movieList in
            self.userViewModel = UserViewModel(movieList: movieList)
            
            DispatchQueue.main.async {
                self.userFilmsTableView.reloadData()
            }
            
        }
        
    }
    
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.userViewModel == nil ? 0 : self.userViewModel.numberOfRowsInSection()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = userFilmsTableView.dequeueReusableCell(withIdentifier: "userFeedCell", for: indexPath) as! UserFeedCell
        let movieViewModel = self.userViewModel.postAtIndex(index: indexPath.row)
        
        cell.filmLabel.text = "\(indexPath.row + 1) - " + "\(movieViewModel.movieName)" + " (\(movieViewModel.movieYear))"
        
        return cell
        
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


