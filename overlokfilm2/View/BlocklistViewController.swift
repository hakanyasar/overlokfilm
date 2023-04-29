//
//  BlocklistViewController.swift
//  overlokfilm2
//
//  Created by hyasar on 13.03.2023.
//

import UIKit
import Firebase

class BlocklistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    @IBOutlet private weak var blocklistTableView: UITableView!
    
    private var userViewModel : UserVcViewModel!
    //private var justUserViewModel : JustUserViewModel!
    var webService = WebService()
    var blocklistViewModel : BlocklistVcViewModel!
    
    var username = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        blocklistTableView.delegate = self
        blocklistTableView.dataSource = self
        
        print("\n\(self.username)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        getData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.blocklistViewModel == nil ? 0 : self.blocklistViewModel.numberOfRowsInSection()
        
        //return self.blocklistViewModel.usernameList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = blocklistTableView.dequeueReusableCell(withIdentifier: "cellOfBlocklist", for: indexPath) as! BlocklistCell
        
        cell.usernameLabel.text = blocklistViewModel.usernameList[indexPath.row]
        
        return cell
    }
    
  
    func getData(){
        
        
        getUserId(username: self.username) { userId in
            self.webService.downloadDataBlocklistVC(userId: userId) { userList in
        
                print("xox \(userList)")
                self.blocklistViewModel = BlocklistVcViewModel(usernameList: userList)
                
                DispatchQueue.main.async {
                    
                    self.blocklistTableView.reloadData()
                }
            }
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
