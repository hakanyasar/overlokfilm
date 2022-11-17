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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
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
                }else{
                    
                    // creating users database collection, document and fields
                    
                    let firestoreDb = Firestore.firestore()
                    //var firestoreRef : DocumentReference? = nil
                    
                    let cuid = Auth.auth().currentUser?.uid as? String
                    
                    
                    firestoreDb.collection("users").document(cuid!).setData(["username" : self.usernameText.text!, "profileImageUrl" : "denemeUrl2"], completion: { error in
                        
                        if let error = error{
                            self.makeAlert(titleInput: "error", messageInput: error.localizedDescription )
                        }
                    })
                    
                    // if user creation was succeed
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                    
                   
                }
                
            }
            
        }else{
            // we are showing alert to user if email or password is void
            makeAlert(titleInput: "hata", messageInput: "email/password/username?")
           
        }
        
    }
    
    func makeAlert (titleInput: String, messageInput: String){
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "tamam", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    
   
    @IBAction func forgotPasswordButtonClicked(_ sender: Any) {
    }
    
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
   
}

