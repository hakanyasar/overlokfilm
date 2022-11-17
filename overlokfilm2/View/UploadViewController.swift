//
//  UploadViewController.swift
//  overlokfilm2
//
//  Created by hyasar on 7.11.2022.
//

import Firebase
import UIKit

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var movieNameText: UITextField!
    @IBOutlet weak var movieYearText: UITextField!
    @IBOutlet weak var directorText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    var imageUrl = ""
    var movieName = ""
    var movieYear = ""
    var movieDirector = ""
    
    var username = "temp"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // in here, we activate clickable feature on image
        imageView.isUserInteractionEnabled = true
        
        // and here, we describe gesture recognizer for upload with click on image
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imageView.addGestureRecognizer(gestureRecognizer)
        
        let gestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer2)
        
        self.getUsername()
        
    }
    
    @objc func chooseImage(){
        
        // we describe picker controller stuff for reach to user gallery
        let pickerController = UIImagePickerController()
        // we assign self to picker controller delegate so we can call some methods that we will use
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    
    // here is about what is gonna happen after choose image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let mediaFolder = storageReference.child("media")
        
        
        // after we create our folder, now we have to cast our UIImage to data because we can't save images to firebase storage as UIImage you know
        if let data = imageView.image?.jpegData(compressionQuality: 0.5) {
            
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
                         
                            let firestorePost = ["imageUrl" : imageUrl!, "postedBy" : self.username, "postMovieName" : self.movieNameText.text!.lowercased(), "postMovieYear" : self.movieYearText.text!, "postDirector" : self.directorText.text!.lowercased(), "postComment" : self.commentText.text!.lowercased(), "date" : self.getDate(), "likes" : 0] as [String : Any]
                            
                            firestoreRef = firestoreDb.collection("posts").addDocument(data: firestorePost, completion: { error in
                                
                                if error != nil{
                                    
                                    self.makeAlert(titleInput: "error", messageInput: error?.localizedDescription ?? "error")
                                    
                                }else{
                                    
                                    // we are giving back default values to views that in upload page
                                    self.imageView.image = UIImage(named: "pluss.png")
                                    self.movieNameText.text = ""
                                    self.movieYearText.text = ""
                                    self.directorText.text = ""
                                    self.commentText.text = ""
                                    
                                    // we actually doing performsegue in here
                                    self.tabBarController?.selectedIndex = 0
                                }
                            })
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
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    
    
    
    @IBAction func nextButtonClicked(_ sender: Any) {
         
        
        // in here firstly we upload image to storage and then we get the url by string
        
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let mediaFolder = storageReference.child("media")
        
        
            if let data = imageView.image?.jpegData(compressionQuality: 0.5) {
                
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
                                
                                self.imageUrl = imageUrl!
                               
                            }
                        }
                    }
                    
                }
            }
            
        self.movieName = self.movieNameText.text!.lowercased()
        self.movieYear = self.movieYearText.text!
        self.movieDirector = self.directorText.text!.lowercased()
        
        performSegue(withIdentifier: "toSaveViewController", sender: nil)
        
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSaveViewController" {
            
            let destinationVC = segue.destination as! SaveViewController
            
            destinationVC.imageUrl = imageUrl
            destinationVC.movieName = movieName
            destinationVC.movieYear = movieYear
            destinationVC.movieDirector = movieDirector
        }
    }
    
 
}
