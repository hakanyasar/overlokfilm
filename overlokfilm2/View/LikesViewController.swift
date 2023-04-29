//
//  LikesViewController.swift
//  overlokfilm2
//
//  Created by hyasar on 25.12.2022.
//

import UIKit
import Firebase

final class LikesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - variables
    
    @IBOutlet private weak var likesTableView: UITableView!
    private var likesViewModel : LikesVcViewModel!
    private var webService = WebService()
    private var likesVSM = LikesViewSingletonModel.sharedInstance
    
    var username = ""
    
    // MARK: - viewDidLoad and viewWillAppear
    
    override func viewDidLoad() {
        super.viewDidLoad()

        likesTableView.delegate = self
        likesTableView.dataSource = self
        
        //page refresh
        likesTableView.refreshControl = UIRefreshControl()
        likesTableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
        

    override func viewWillAppear(_ animated: Bool) {
        
        getData()
    }
    
    
    // MARK: - tableView functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.likesViewModel == nil ? 0 : self.likesViewModel.numberOfRowsInSection()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = likesTableView.dequeueReusableCell(withIdentifier: "cellOfLikes", for: indexPath) as! LikesCell
        
        let postViewModel = self.likesViewModel.postAtIndex(index: indexPath.row)
        
        cell.filmLabel.text = "\(indexPath.row + 1) - " + "\(postViewModel.postMovieName)" + " (\(postViewModel.postMovieYear))"
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let postViewModel = self.likesViewModel.postAtIndex(index: indexPath.row)
        
        likesVSM.postId = postViewModel.postId
        
        performSegue(withIdentifier: "toPostDetailVCFromLikes", sender: indexPath)
        
        // this command prevent gray colour when come back after selection
        likesTableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toPostDetailVCFromLikes" {
            
            let destinationVC = segue.destination as! PostDetailViewController
            
            destinationVC.postId = likesVSM.postId
            
        }
        
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
    
    
    @objc private func didPullToRefresh(){
        
        getData()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            
            self.likesTableView.refreshControl?.endRefreshing()
        }
    }
    
    
    func getUserId(username: String, completion: @escaping (String) -> Void) {
                
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("users").whereField("username", isEqualTo: "\(username)").getDocuments(source: .server) { snapshot, error in
            
            if error != nil {
                
                print(error?.localizedDescription ?? "error")
                self.makeAlert(titleInput: "error", messageInput: "\npage couldn't load. \nplease try again later.")
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
    
    // MARK: makeAlert
    
    func makeAlert(titleInput: String, messageInput: String){
        
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
