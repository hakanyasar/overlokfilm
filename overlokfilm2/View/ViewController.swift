//
//  ViewController.swift
//  overlokfilm2
//
//  Created by hyasar on 7.11.2022.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var userProfileImage: UIImageView!
    
    @IBOutlet weak var signInButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        setAppearanceTextFields()
    }

    
    
    @IBAction func signInClicked(_ sender: Any) {
        
        if emailText.text != "" && passwordText.text != "" {
            
            Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!) { authdata, error in
                
                if error != nil{
                    self.makeAlert(titleInput: "error", messageInput: error?.localizedDescription ?? "error")
                }else{
                    // if email and password are true
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
            }
            
            
        }else{
            // we are showing alert to user if email or password is void
            makeAlert(titleInput: "error", messageInput: "username/password?")
        }
        
    }
    
    
    
    @IBAction func signUpClicked(_ sender: Any) {
        
        
        if emailText.text != "" && passwordText.text != "" && usernameText.text != "" {
            
            Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!) { authdata, error in
                
                if error != nil{
                    self.makeAlert(titleInput: "error", messageInput: error?.localizedDescription ?? "error")
                }else {
                    
                    self.uploadDefaultUserImage { imageUrl in
                        
                        // creating users database collection, document and fields
                        
                        let firestoreDb = Firestore.firestore()
                        //var firestoreRef : DocumentReference? = nil
                        
                        let cuid = Auth.auth().currentUser?.uid as? String
                        
                        
                        firestoreDb.collection("users").document(cuid!).setData(["username" : self.usernameText.text!, "email" : self.emailText.text! ,"profileImageUrl" : imageUrl], completion: { error in
                            
                            if let error = error{
                                self.makeAlert(titleInput: "error", messageInput: error.localizedDescription )
                            }
                        })
                        
                        // if user creation was succeed
                        self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                     
                        
                    }
                    
                }
                
            }
            
        }
        
     
    }
    
    
    func makeAlert (titleInput: String, messageInput: String){
        
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    
   
    @IBAction func forgotPasswordButtonClicked(_ sender: Any) {
    }
    
    
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    func setAppearanceTextFields() {
        
        emailText.layer.cornerRadius = 15
        emailText.layer.borderColor = UIColor.gray.cgColor
        emailText.layer.borderWidth = 1
        
        passwordText.layer.cornerRadius = 15
        passwordText.layer.borderColor = UIColor.gray.cgColor
        passwordText.layer.borderWidth = 1
        
        usernameText.layer.cornerRadius = 15
        usernameText.layer.borderColor = UIColor.gray.cgColor
        usernameText.layer.borderWidth = 1
        
        signInButton.backgroundColor = .systemGray5
        signInButton.layer.cornerRadius = 15
        signInButton.layer.borderColor = UIColor.gray.cgColor
        signInButton.layer.borderWidth = 1
         
    }
    
    
    func uploadDefaultUserImage(completion: @escaping (String) -> Void) {
        
        // önce var mı yok mu kotrol et varsa hiçbir işlem yapma yoksa yükle storage a
        
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let userImageFolder = storageReference.child("userDefaultProfileImage")
        
        
        if let data = userProfileImage.image?.jpegData(compressionQuality: 0.5)  {
            
            let imageReference = userImageFolder.child("userDefaultImage.png")
            
            imageReference.putData(data) { metadata, error in
                
                if error != nil{
                    self.makeAlert(titleInput: "error", messageInput: error?.localizedDescription ?? "error")
                }else {
                    
                    imageReference.downloadURL { url, error in
                        
                        if error == nil {
                            
                            let imageUrl = url?.absoluteString
                            
                            completion(imageUrl!)
                            
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
        
                
            }
            
}

