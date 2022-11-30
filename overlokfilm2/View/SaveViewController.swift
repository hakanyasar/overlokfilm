//
//  SaveViewController.swift
//  overlokfilm2
//
//  Created by hyasar on 15.11.2022.
//

import Foundation
import UIKit
import Firebase

class SaveViewController: UIViewController, UITextViewDelegate {
    
    
    @IBOutlet weak var sendButton: UIBarButtonItem!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
        
    let uploadSVM = UploadViewSingletonModel.sharedInstance
    
    var username = "temp"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTextView.delegate = self
        
        // we are starting the cursor with this method
        commentTextView.becomeFirstResponder()
        
        putInitialValueToLabel()
        
        self.getUsername()
        
    }
    
    
    @IBAction func sendButtonClicked(_ sender: Any) {
        
        
        // for deleting whitespaces and blank lines at the beginning and at the and
        let trimmedCommentText = commentTextView.text.trimmingLeadingAndTrailingSpaces()
        
        uploadSVM.comment = trimmedCommentText.lowercased()
        
        
        if uploadSVM.comment != "" {
            
            // storage
            
            let storage = Storage.storage()
            let storageReference = storage.reference()
            
            let mediaFolder = storageReference.child("media")
            
            
            if let data = uploadSVM.imageView.jpegData(compressionQuality: 0.5) {
                
                // now we can save this data to storage
                
                let uuid = UUID().uuidString
                
                let imageReference = mediaFolder.child("\(uuid).jpg")
                
                imageReference.putData(data, metadata: nil) { metadata, error in
                    
                    if error != nil{
                        self.makeAlert(titleInput: "error", messageInput: error?.localizedDescription ?? "error")
                    }else{
                        
                        imageReference.downloadURL { url, error in
                            
                            if error == nil {
                                
                                let imageUrl = url?.absoluteString
                                
                                // database
                                
                                let firestoreDb = Firestore.firestore()
                                var firestoreRef : DocumentReference? = nil
                                
                                
                                let firestorePost = ["postId" : "\(uuid)", "imageUrl" : imageUrl!, "postedBy" : self.username, "postMovieName" : self.uploadSVM.movieName, "postMovieYear" : self.uploadSVM.movieYear, "postDirector" : self.uploadSVM.movieDirector, "postComment" : self.uploadSVM.comment, "date" : self.getDate(), "likes" : 0] as [String : Any]
                                
                                firestoreRef = firestoreDb.collection("posts").addDocument(data: firestorePost, completion: { error in
                                    
                                    if error != nil{
                                        
                                        self.makeAlert(titleInput: "error", messageInput: error?.localizedDescription ?? "error")
                                        
                                    }else{
                                        
                                        // we actually doing performsegue in here
                                        self.tabBarController?.selectedIndex = 0
                                        
                                        self.putDefaultValues()
                                    }
                                })
                                
                            
                            }
                            
                        }
                    }
                }
                
            }
            
        }else{
            makeAlert(titleInput: "error", messageInput: "comment ?")
        }
        
    }


    func getUsername(){
        
        let cuid = Auth.auth().currentUser?.uid as? String
        
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("users").document(cuid!).getDocument { document, error in
            
            if error != nil{
                self.makeAlert(titleInput: "error", messageInput: error?.localizedDescription ?? "error")
            }else{
                
                if let document = document, document.exists {
                    
                    if let dataDescription = document.get("username") as? String{
                        self.username = dataDescription
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

    
    func getDate() -> String{
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let dateString = formatter.string(from: date)
       
        return dateString
        
    }
    
    func putInitialValueToLabel(){
        
        if uploadSVM.movieName != "" && uploadSVM.movieYear != "" {
            commentLabel.text = "\(uploadSVM.movieName)" + " (\(uploadSVM.movieYear))"
        }else {
            commentLabel.text = "movie name wasn't found!"
        }
    }
 
    
    func putDefaultValues(){
        
        commentTextView.text = ""
    }
    
    
}


extension String {
    
    func trimmingLeadingAndTrailingSpaces(using characterSet: CharacterSet = .whitespacesAndNewlines) -> String {
        return trimmingCharacters(in: characterSet)
    }
    
}
