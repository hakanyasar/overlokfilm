//
//  LikesViewController.swift
//  overlokfilm2
//
//  Created by hyasar on 25.12.2022.
//

import UIKit
import Firebase

class LikesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var likesTableView: UITableView!
    private var likesViewModel : LikesVcViewModel!
    var webService = WebService()
    
    var username = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        likesTableView.delegate = self
        likesTableView.dataSource = self
    }
        

    override func viewWillAppear(_ animated: Bool) {
        
        getData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return self.likesViewModel == nil ? 0 : self.likesViewModel.numberOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = likesTableView.dequeueReusableCell(withIdentifier: "cellOfLikes", for: indexPath) as! LikesCell
        
        let postViewModel = self.likesViewModel.postAtIndex(index: indexPath.row)
        
        cell.filmLabel.text = "\(indexPath.row + 1) - " + "\(postViewModel.postMovieName)" + " (\(postViewModel.postMovieYear))"
        
        
        return cell
    }
    
    
    func getData(){
        
        getUserId(username: self.username) { userId in
            
            self.webService.downloadDataLikesVC(userId: userId) { postList in
                
                self.likesViewModel = LikesVcViewModel(postList: postList)
                
                DispatchQueue.main.async {
                    
                    self.likesViewModel.postList.sort { p1, p2 in
                        
                        return p1.postDate.compare(p2.postDate) == .orderedDescending
                    }
                }
                
                DispatchQueue.main.async {
                    
                    self.likesTableView.reloadData()
                }
                
            }
            
        }
        
    }
    
    
    
    func getUserId(username: String, completion: @escaping (String) -> Void) {
                
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("users").whereField("username", isEqualTo: "\(username)").getDocuments(source: .server) { snapshot, error in
            
            if error != nil {
                
                print(error?.localizedDescription ?? "error")
            }else {
                                    
                DispatchQueue.global().async {
                    
                    for document in snapshot!.documents {
                            
                            let userId = document.documentID
                            completion(userId)
                    }
                    
                }
                      
            }
            
        }
        
    }
    
    
}
