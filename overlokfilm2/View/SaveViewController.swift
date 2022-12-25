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
    var webService = WebService()
    
    private var saveViewModel : SaveVcViewModel!
    
    var postIdWillEdit = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTextView.delegate = self
        
        // we are starting the cursor with this method
        commentTextView.becomeFirstResponder()
        setAllPageDatas()
                
    }

    
    @IBAction func sendButtonClicked(_ sender: Any) {
        
        print("postIdWillEdit: \(self.postIdWillEdit)")
        
        // for deleting whitespaces and blank lines at the beginning and at the and
        let trimmedCommentText = commentTextView.text.trimmingLeadingAndTrailingSpaces()
        uploadSVM.comment = trimmedCommentText.lowercased()
        
        if postIdWillEdit == "" {
            
            // so we will publish new post
            print("so we will publish new post")
            
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
                                    
                                    self.getProfileImage { profileImageUrl in
                                        
                                        self.getUsername { curUsername in
                                            
                                            let firestorePost = ["postId" : "\(uuid)", "imageUrl" : imageUrl!, "postedBy" : "\(curUsername)", "postMovieName" : self.uploadSVM.movieName, "postMovieYear" : self.uploadSVM.movieYear, "postDirector" : self.uploadSVM.movieDirector, "postComment" : self.uploadSVM.comment, "date" : self.getDate(), "userIconUrl" : "\(profileImageUrl)", "isLiked" : false ,"likes" : 0] as [String : Any]
                                            
                                            
                                            firestoreRef = firestoreDb.collection("posts").addDocument(data: firestorePost, completion: { error in
                                                
                                                if error != nil{
                                                    
                                                    self.makeAlert(titleInput: "error", messageInput: error?.localizedDescription ?? "error")
                                                    
                                                }else{
                                        
                                                    self.makeAlert(titleInput: "", messageInput: "your post has been published.")
                                                    
                                                    // we actually doing performsegue in here
                                                    self.tabBarController?.selectedIndex = 0
                                                    self.navigationController?.popViewController(animated: true)
                                                    
                                                    self.increasePostCount()
                                                }
                                            })
                                            
                                            
                                        }
                                    
                                    }
                                
                                }
                                
                            }
                        }
                    }
                    
                }
                
            }else{
                makeAlert(titleInput: "error", messageInput: "there is no comment.")
            }
            
        }else {
             // so we came from edit button
            print("// so we came from edit button")
            
            
            if uploadSVM.comment != "" {
                
                // so in here we are sending editted data anymore and we will update post on database
                
                let firestoreDb = Firestore.firestore()
                
                firestoreDb.collection("posts").whereField("postId", isEqualTo: "\(postIdWillEdit)").getDocuments { snapshot, error in
                    
                    if error != nil {
                        
                        print(error?.localizedDescription ?? "error")
                    }else {
                        
                        for document in snapshot!.documents {
                            
                            DispatchQueue.global().async {
                                
                                document.reference.updateData(["postComment" : "\(self.uploadSVM.comment)"])
                            }
                           
                        }
                        
                        // we actually doing performsegue in here
                        self.tabBarController?.selectedIndex = 0
                        self.navigationController?.popToRootViewController(animated: true)
                        //self.makeAlert(titleInput: "", messageInput: "your post has been edited.")
                    }
                    
                }
                                
            }else {
                
                makeAlert(titleInput: "error", messageInput: "please write something.")
            }
            
        }
        
    }

    
    func getUsername(completion: @escaping (String) -> Void) {
        
        let cuid = Auth.auth().currentUser?.uid as? String
        
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("users").document(cuid!).getDocument { document, error in
            
            if error != nil{
                self.makeAlert(titleInput: "error", messageInput: error?.localizedDescription ?? "error")
            }else{
                
                if let document = document, document.exists {
                    
                    if let dataDescription = document.get("username") as? String{
                        
                        completion(dataDescription)
                    } else {
                        print("document field was not gotten")
                    }
                }
                
            }
            
        }
        
        
    }

    func increasePostCount(){
        
        guard let cuid = Auth.auth().currentUser?.uid as? String else {return}
        
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("users").document(cuid).getDocument { document, error in
            
            if error != nil{
                
                print("error: \(String(describing: error?.localizedDescription))")
                
            }else {
                
                DispatchQueue.global().async {
                    
                    if let document = document, document.exists {
                        
                        if let postCount = document.get("postCount") as? Int {
                                        
                            // we are setting new postCount
                            let postCountDic = ["postCount" : postCount + 1] as [String : Any]
                            
                            firestoreDb.collection("users").document(cuid).setData(postCountDic, merge: true)
                            
                        } else {
                            print("document field was not gotten")
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

    
    func getDate() -> String{
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let dateString = formatter.string(from: date)
       
        return dateString
        
    }
    
    
    func getProfileImage(completion : @escaping (String) -> Void) {
        
        let cuid = Auth.auth().currentUser?.uid as? String
        
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("users").document(cuid!).getDocument { document, error in
            
            if error != nil{
                print(error?.localizedDescription ?? "error")
            }else{
                
                if let document = document, document.exists {
                                            
                        if let dataDescription = document.get("profileImageUrl") as? String{
                            
                            completion(dataDescription)
                            
                        } else {
                            print("document field was not gotten")
                        }
                   
                }
                
            }
            
        }
        
    }
    
    
    func setAllPageDatas(){
        
        if postIdWillEdit == "" {
            
            // so we came for publishing new post
            
            if uploadSVM.movieName != "" && uploadSVM.movieYear != "" {
                commentLabel.text = "\(uploadSVM.movieName)" + " (\(uploadSVM.movieYear))"
            }else {
                commentLabel.text = "movie name wasn't found!"
            }
            
        }else {
            
            // so we came for editting post
            
            webService.downloadDataSaveVCForEdit(postId: self.postIdWillEdit) { post in
                
                DispatchQueue.main.async {
                    
                    self.saveViewModel = SaveVcViewModel(post: post)
                    
                    self.commentLabel.text = "\(self.saveViewModel.post.postMovieName)" + " (\(self.saveViewModel.post.postMovieYear))"
                    self.commentTextView.text = self.saveViewModel.post.postMovieComment
                    
                }
                
            }
            
        }
       
    }
    
}


extension String {
    
    func trimmingLeadingAndTrailingSpaces(using characterSet: CharacterSet = .whitespacesAndNewlines) -> String {
        return trimmingCharacters(in: characterSet)
    }
    
}
