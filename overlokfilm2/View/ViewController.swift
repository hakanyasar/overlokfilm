//
//  ViewController.swift
//  overlokfilm2
//
//  Created by hyasar on 7.11.2022.
//

import UIKit
import Firebase
import FirebaseStorage

final class ViewController: UIViewController {
    
    
    // MARK: - variables
    
    @IBOutlet private weak var appIcon: UIImageView!
    
    @IBOutlet private weak var emailText: UITextField!
    @IBOutlet private weak var passwordText: UITextField!
    @IBOutlet private weak var usernameText: UITextField!
    @IBOutlet private weak var forgotPasswordButton: UIButton!
    @IBOutlet private weak var userProfileImage: UIImageView!
    
    @IBOutlet private weak var signInButton: UIButton!
    
    var usernameCount = 0
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        setAppearance()
    }
    
    
    
    // MARK: - functions
    
    @IBAction func signInClicked(_ sender: Any) {
        
        if emailText.text != "" && passwordText.text != "" {
            
            Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!) { authdata, error in
                
                if error != nil{
                    
                    self.makeAlert(titleInput: "error", messageInput: "\nan error occured. \nplease try again sign in later. \nthere may not be such a user like this.")
                }else{
                    // if email and password are true
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
            }
            
            
        }else{
            // we are showing alert to user if email or password is void
            makeAlert(titleInput: "error", messageInput: "\nusername/password?")
        }
        
    }
    
    
    
    @IBAction func signUpClicked(_ sender: Any) {
        
        if emailText.text != "" && passwordText.text != "" && usernameText.text != "" {
            
            if let trimmingUsername = usernameText.text?.trimmingLeadingAndTrailingSpaces() {
                
                if trimmingUsername.count > 42 {
                    
                    self.makeAlert(titleInput: "number of characters error", messageInput: "\nmax number of characters must be 42 for username.")
                } else {
                    
                    if isThereNonEnglishCharacter(text: trimmingUsername) {
                        
                        makeAlert(titleInput: "special character error", messageInput: "\nplease just type only english characters for username.")
                    }else {
                        
                        if trimmingUsername.count < 3 {
                            
                            makeAlert(titleInput: "number of characters error", messageInput: "\nmin number of characters must be 3 for username.")
                        }else{
                            
                            Auth.auth().createUser(withEmail: self.emailText.text!, password: self.passwordText.text!) { authdata, error in
                                
                                if error != nil{
                                    
                                    self.makeAlert(titleInput: "error", messageInput: "\nan error occured. \nplease try again sign up later. \nthis e-mail adress may has been taken.")
                                }else {
                                    
                                    self.uploadDefaultUserImage { imageUrl in
                                        
                                        // creating users database collection, document and fields
                                        
                                        let firestoreDb = Firestore.firestore()
                                        
                                        guard let cuid = Auth.auth().currentUser?.uid as? String else {return}
                                        
                                        
                                        firestoreDb.collection("users").document(cuid).setData(["username" : trimmingUsername, "email" : self.emailText.text! ,"profileImageUrl" : imageUrl, "bio" : "", "postCount" : 0, "followersCount" : 0, "followingCount" : 0], completion: { error in
                                            
                                            if let error = error{
                                                self.makeAlert(titleInput: "error", messageInput: error.localizedDescription )
                                            }
                                        })
                                        
                                        self.isUsernameExist(username: trimmingUsername) { result in
                                            
                                            if result == true{
                                                self.removeDocumentFromUsersAndDeleteAccount { result in
                                                    self.makeAlert(titleInput: "", messageInput: "\nthis username has been taken. \nplease choose a different username.")
                                                }
                                            }else{
                                                
                                                // if user creation was succeed
                                                self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                                                self.usernameText.isHidden = true
                                            }
                                        }
                                        
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    func isUsernameExist(username: String, completion: @escaping (Bool) -> Void){
                
        self.usernameCount = 0
        
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("users").whereField("username", isEqualTo: "\(username)").getDocuments(source: .server) { querySnapshot, error in
            
            if let error = error {
                print("\n xx error getting documents: \(error)")
                
            } else {
                
                for document in querySnapshot!.documents{
                    
                    self.usernameCount = self.usernameCount + 1
                }
                
                if self.usernameCount > 1{
                    completion(true)
                }else{
                    completion(false)
                }
            }
        }
        
    }
    
    func deleteAccount(){
        
        let user = Auth.auth().currentUser
        
        user?.delete { error in
            if let error = error {
                print("an error occured.")
            } else {
                print("\n xx user account has been deleted.")
            }
        }
        
    }
    
    func removeDocumentFromUsersAndDeleteAccount(completion: @escaping (Bool) -> Void){
        
        guard let cuid = Auth.auth().currentUser?.uid as? String else { return }
        
        let firestoreDatabase = Firestore.firestore()
        
        firestoreDatabase.collection("users").document(cuid).getDocument(source: .server) { document, error in
            
            if let document = document, document.exists{
                
                document.reference.delete()
                self.deleteAccount()
                completion(true)
            }else{
                print("document doesn^t exist")
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
    
    // MARK: setAppearance
    
    func setAppearance() {
        
        emailText.layer.masksToBounds = true
        emailText.clearButtonMode = .always
        emailText.layer.cornerRadius = 15
        emailText.layer.borderColor = UIColor.gray.cgColor
        emailText.layer.borderWidth = 1
        
        passwordText.layer.masksToBounds = true
        passwordText.clearButtonMode = .always
        passwordText.layer.cornerRadius = 15
        passwordText.layer.borderColor = UIColor.gray.cgColor
        passwordText.layer.borderWidth = 1
        
        usernameText.layer.masksToBounds = true
        usernameText.clearButtonMode = .always
        usernameText.layer.cornerRadius = 15
        usernameText.layer.borderColor = UIColor.gray.cgColor
        usernameText.layer.borderWidth = 1
        
        signInButton.layer.masksToBounds = true
        signInButton.backgroundColor = .systemGray5
        signInButton.layer.cornerRadius = 15
        signInButton.layer.borderColor = UIColor.gray.cgColor
        signInButton.layer.borderWidth = 1
        
    }
    
    
    func uploadDefaultUserImage(completion: @escaping (String) -> Void) {
        
        // firstly check whether it is exist. if it is exist don't do anything but if it is not exist load to the storage
        
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let userImageFolder = storageReference.child("userDefaultProfileImage")
        
        
        if let data = userProfileImage.image?.jpegData(compressionQuality: 0.5)  {
            
            let imageReference = userImageFolder.child("userDefaultImage.png")
            
            imageReference.putData(data) { metadata, error in
                
                if error != nil{
                    
                    self.makeAlert(titleInput: "error", messageInput: "\nan error occured. \nplease try again later.")
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
    
    
    func isThereNonEnglishCharacter(text: String) -> Bool {
        
        let characterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ")
        
        if text.rangeOfCharacter(from: characterSet.inverted) != nil {
            
            return true
        }else {
            
            return false
        }
        
        
    }
    
}

