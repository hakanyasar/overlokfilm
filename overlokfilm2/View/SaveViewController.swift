//
//  SaveViewController.swift
//  overlokfilm2
//
//  Created by hyasar on 15.11.2022.
//

import UIKit
import Firebase

class SaveViewController: UIViewController, UITextViewDelegate {

    
    @IBOutlet weak var sendButton: UIBarButtonItem!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    

    // variables
    
    var imageUrl = ""
    var movieName = ""
    var movieYear = ""
    var movieDirector = ""
    
    var username = "temp"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commentTextView.delegate = self
        
        // we are starting the cursor with this method
        commentTextView.becomeFirstResponder()
        
        if self.movieName != "" {
            commentLabel.text = "\(self.movieName)" + " (\(self.movieYear))"
        }else {
            commentLabel.text = "movie name wasn't found!"
        }
        
        self.getUsername()
        
    }
    
    
    @IBAction func sendButtonClicked(_ sender: Any) {
        
        // for deleting whitespaces and blank lines at the beginning and at the and
        var trimmedCommentText = commentTextView.text.trimmingLeadingAndTrailingSpaces()
        
        
        if self.movieName != "" && self.movieYear != "" && self.movieDirector != "" && commentTextView.text != "" && self.imageUrl != "" {
            
            let firestoreDb = Firestore.firestore()
            var firestoreRef : DocumentReference? = nil
         
            
            let firestorePost = ["imageUrl" : self.imageUrl, "postedBy" : self.username, "postMovieName" : self.movieName, "postMovieYear" : self.movieYear, "postDirector" : self.movieDirector, "postComment" : trimmedCommentText.lowercased(), "date" : self.getDate(), "likes" : 0] as [String : Any]
            
            firestoreRef = firestoreDb.collection("posts").addDocument(data: firestorePost, completion: { error in
                
                if error != nil{
                    
                    self.makeAlert(titleInput: "error", messageInput: error?.localizedDescription ?? "error")
                    
                }else{
                    
                    // we are giving back default values to views that in upload page
             
                    
                    /*
                    self.imageView.image = UIImage(named: "pluss.png")
                    self.movieNameText.text = ""
                    self.movieYearText.text = ""
                    self.directorText.text = ""
                    self.commentText.text = ""
                    */
                     
                    // we actually doing performsegue in here
                    self.tabBarController?.selectedIndex = 0
                }
            })
            
        }else {
            makeAlert(titleInput: "error", messageInput: "movie name/year/director/images one of these is missing")
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
    
}

extension String {
    func trimmingLeadingAndTrailingSpaces(using characterSet: CharacterSet = .whitespacesAndNewlines) -> String {
        return trimmingCharacters(in: characterSet)
    }
}
