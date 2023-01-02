//
//  UploadViewController.swift
//  overlokfilm2
//
//  Created by hyasar on 7.11.2022.
//

import Firebase
import UIKit

final class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    // MARK: - variables
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var movieNameText: UITextField!
    @IBOutlet private weak var movieYearText: UITextField!
    @IBOutlet private weak var directorText: UITextField!
    @IBOutlet private weak var nextButton: UIBarButtonItem!
    
    var username = "temp"
    var imageId = ""
    
    // MARK: - viewDidLoad and viewDidDisappear
    
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
        
        putIdToImage()
        
        setAppearanceTextFields()
                
    }
   
    
    override func viewDidDisappear(_ animated: Bool) {
        
        imageView.image = UIImage(named: "uploadIcon.png")
        movieNameText.text = ""
        movieYearText.text = ""
        directorText.text = ""
        
        imageId = "uploadIcon.png"
        
    }
    
    // MARK: - functions
    
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
        
        imageId = "not uploadIcon.png"
        
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
                self.makeAlert(titleInput: "error", messageInput: "\nan error occured. \nplease try again later.")
            }else{
                
                if let document = document, document.exists {
                    
                    if let dataDescription = document.get("username") as? String{
                        self.username = dataDescription
                        
                    } else {
                        print("\ndocument field was not gotten")
                    }
                }
                
            }
            
        }
        
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    
    
    @IBAction func nextButtonClicked(_ sender: Any) {
         
           
        let uploadVSM = UploadViewSingletonModel.sharedInstance
        
        let trimmedMovieNameText = movieNameText.text?.trimmingLeadingAndTrailingSpaces()
        let trimmedMovieYearText = movieYearText.text?.trimmingLeadingAndTrailingSpaces()
        let trimmedDirectorText = directorText.text?.trimmingLeadingAndTrailingSpaces()
        
        print("\n trimmedMovieNameText: \(String(describing: trimmedMovieNameText)) \n")
        
        if trimmedMovieNameText != "" && trimmedMovieYearText != "" && trimmedDirectorText != "" && imageId != "uploadIcon.png" {
                        
            if trimmedMovieNameText!.count >= 40{
                
                makeAlert(titleInput: "number of characters error", messageInput: "\nmax number of characters must be 40 for movie name.")
            }else{
                
                if trimmedMovieYearText?.count != 4{
                    
                    makeAlert(titleInput: "number of characters error", messageInput: "\nnumber of characters must be 4 for movie year.")
                }else{
                    
                    if isThereNonNumberCharacter(text: trimmedMovieYearText!){
                        
                        makeAlert(titleInput: "non number character error", messageInput: "\nyear field must be only numbers.")
                    }else{
                        
                        if trimmedDirectorText!.count >= 39{
                            
                            makeAlert(titleInput: "number of characters error", messageInput: "\nmax number of characters must be 39 for dirextor name.")
                        }else{
                            
                            if let chosenImage = imageView.image {
                                
                                uploadVSM.movieName = trimmedMovieNameText!.lowercased()
                                uploadVSM.movieYear = trimmedMovieYearText!
                                uploadVSM.movieDirector = trimmedDirectorText!.lowercased()
                                uploadVSM.imageView = chosenImage
                                
                                self.performSegue(withIdentifier: "toSaveViewController", sender: nil)
                                
                            }else{
                                makeAlert(titleInput: "error", messageInput: "\nimage error")
                            }
                        }
                    }
                      
                }
            }
            
        }else{
            
            makeAlert(titleInput: "error", messageInput: "\nmovie name / year / director?\nor movie image?")
        }
                
        
    }

 
    func putIdToImage(){
        
        imageView.image?.accessibilityIdentifier = "uploadIcon.png"
        self.imageId = (imageView.image?.accessibilityIdentifier!)!
        
    }
    
    func setAppearanceTextFields() {
        
        movieNameText.layer.masksToBounds = true
        movieNameText.layer.cornerRadius = 15
        movieNameText.layer.borderColor = UIColor.gray.cgColor
        movieNameText.layer.borderWidth = 1
        
        movieYearText.layer.masksToBounds = true
        movieYearText.layer.cornerRadius = 15
        movieYearText.layer.borderColor = UIColor.gray.cgColor
        movieYearText.layer.borderWidth = 1
        
        directorText.layer.masksToBounds = true
        directorText.layer.cornerRadius = 15
        directorText.layer.borderColor = UIColor.gray.cgColor
        directorText.layer.borderWidth = 1
        
        
    }
    
    func isThereNonNumberCharacter(text: String) -> Bool {
        
        let characterSet = CharacterSet(charactersIn: "0123456789 ")
        
        if text.rangeOfCharacter(from: characterSet.inverted) != nil {
            
            return true
        }else {
            
            return false
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
