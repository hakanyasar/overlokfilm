//
//  EditBioViewController.swift
//  overlokfilm2
//
//  Created by hyasar on 22.12.2022.
//

import UIKit
import Firebase

class EditBioViewController: UIViewController {
    
    
    @IBOutlet weak var editBioLabel: UILabel!
    
    @IBOutlet weak var editBioTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editBioTextView.becomeFirstResponder()
        
        getBio()
    }
    
    
    func getBio(){
        
        guard let cuid = Auth.auth().currentUser?.uid as? String else {return}
        
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("users").document(cuid).getDocument(source: .server) { document, error in
            
            if error != nil{
                
                print("error: \(String(describing: error?.localizedDescription))")
                
            }else {
                
                if let document = document, document.exists {
                    
                    DispatchQueue.global().async {
                        
                        if let bio = document.get("bio") as? String {
                            
                            DispatchQueue.main.async {
                                
                                self.editBioTextView.text = bio
                            }
                            
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let trimmedCommentText = editBioTextView.text.trimmingLeadingAndTrailingSpaces().lowercased()
        
        if trimmedCommentText.count > 42{
            
            self.makeAlert(titleInput: "number of characters error", messageInput: "\nmax number of characters must be 42 for bio.")
            
        }else{
            
            guard let cuid = Auth.auth().currentUser?.uid as? String else {return}
            
            let firestoreDb = Firestore.firestore()
            
            firestoreDb.collection("users").document(cuid).setData(["bio" : "\(trimmedCommentText)"], merge: true) { error in
                
                if let error = error {
                    
                        print("Error writing document: \(error)")
                    } else {
                        
                        print("Document successfully written!")
                        
                        // we actually doing performsegue in here
                        self.tabBarController?.selectedIndex = 0
                        self.navigationController?.popViewController(animated: true)
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
