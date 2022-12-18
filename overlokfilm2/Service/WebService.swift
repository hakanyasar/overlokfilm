//
//  WebService.swift
//  overlokfilm2
//
//  Created by hyasar on 7.11.2022.
//

import Foundation
import Firebase

class WebService {
    
    var post = Post()
    var postList = [Post]()
    
    
    func downloadData(completion: @escaping ([Post]) -> Void ){
        
        let firestoreDatabase = Firestore.firestore()
        
        firestoreDatabase.collection("posts").order(by: "date", descending: true).addSnapshotListener { snapshot, error in
            
            if error != nil {
                
                print(error?.localizedDescription ?? "error")
                
            }else {
                
                if snapshot?.isEmpty != true && snapshot != nil {
                    
                    self.postList.removeAll(keepingCapacity: false)
                    
                    DispatchQueue.global().async {
                        
                        for document in snapshot!.documents {
                                                        
                            if let postId = document.get("postId") as? String {
                                self.post.postId = postId
                            }
                            
                            if let iconUrl = document.get("userIconUrl") as? String {
                                self.post.userIconUrl = iconUrl
                            }
                            
                            if let postedBy = document.get("postedBy") as? String {
                                self.post.postedBy = postedBy
                            }
                            
                            if let postMovieName = document.get("postMovieName") as? String {
                                self.post.postMovieName = postMovieName
                            }
                            
                            if let postMovieYear = document.get("postMovieYear") as? String {
                                self.post.postMovieYear = postMovieYear
                            }
                            
                            if let postMovieDirector = document.get("postDirector") as? String {
                                self.post.postMovieDirector = postMovieDirector
                            }
                            
                            if let postMovieComment = document.get("postComment") as? String {
                                self.post.postMovieComment = postMovieComment
                            }
                            
                            if let postDate = document.get("date") as? String {
                                self.post.postDate = postDate
                            }
                            
                            self.postList.append(self.post)
                            
                        }
                        completion(self.postList)
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    
    func downloadDataUserVC(uName : String, completion: @escaping ([Post]) -> Void){
        
        let firestoreDatabase = Firestore.firestore()
               
        firestoreDatabase.collection("posts").whereField("postedBy", isEqualTo: uName).order(by: "date", descending: false).addSnapshotListener { snapshot, error in
            
            if error != nil{
                print(error?.localizedDescription ?? "error")
                
            }else {
                
                if snapshot?.isEmpty != true && snapshot != nil {
                    
                    self.postList.removeAll(keepingCapacity: false)
                    
                    DispatchQueue.global().async {
                        
                        for document in snapshot!.documents {
                            
                            if let postId = document.get("postId") as? String {
                                self.post.postId = postId
                            }
                                                        
                            if let postedBy = document.get("postedBy") as? String {
                                self.post.postedBy = postedBy
                            }
                            
                            if let postMovieName = document.get("postMovieName") as? String {
                                self.post.postMovieName = postMovieName
                            }
                            
                            if let postMovieYear = document.get("postMovieYear") as? String {
                                self.post.postMovieYear = postMovieYear
                            }
                            
                            if let postMovieDirector = document.get("postDirector") as? String {
                                self.post.postMovieDirector = postMovieDirector
                            }
                            
                            if let postMovieComment = document.get("postComment") as? String {
                                self.post.postMovieComment = postMovieComment
                            }
                            
                            if let postDate = document.get("date") as? String {
                                self.post.postDate = postDate
                            }
                            
                            self.postList.append(self.post)
                            
                        }
                        completion(self.postList)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    func downloadDataDetailPostVC(postID : String, completion: @escaping ([Post]) -> Void){
        
        //let userVSM = UserViewSingletonModel.sharedInstance
        //let feedVSM = FeedViewSingletonModel.sharedInstance
        
        let firestoreDatabase = Firestore.firestore()
               
        firestoreDatabase.collection("posts").whereField("postId", isEqualTo: "\(postID)").addSnapshotListener { snapshot, error in
            
            if error != nil{
                print(error?.localizedDescription ?? "error")
                
            }else {
                
                if snapshot?.isEmpty != true && snapshot != nil {
                    
                    self.postList.removeAll(keepingCapacity: false)
                    
                    DispatchQueue.global().async {
                        
                        for document in snapshot!.documents {
                            
                            if let postId = document.get("postId") as? String {
                                self.post.postId = postId
                            }
                            
                            if let imageUrl = document.get("imageUrl") as? String {
                                self.post.postImageUrl = imageUrl
                            }
                            
                            if let iconUrl = document.get("userIconUrl") as? String {
                                self.post.userIconUrl = iconUrl
                            }
                            
                            if let postedBy = document.get("postedBy") as? String {
                                self.post.postedBy = postedBy
                            }
                            
                            if let postMovieName = document.get("postMovieName") as? String {
                                self.post.postMovieName = postMovieName
                            }
                            
                            if let postMovieYear = document.get("postMovieYear") as? String {
                                self.post.postMovieYear = postMovieYear
                            }
                            
                            if let postMovieDirector = document.get("postDirector") as? String {
                                self.post.postMovieDirector = postMovieDirector
                            }
                            
                            if let postMovieComment = document.get("postComment") as? String {
                                self.post.postMovieComment = postMovieComment
                            }
                            
                            if let postDate = document.get("date") as? String {
                                self.post.postDate = postDate
                            }
                            
                            self.postList.append(self.post)
                            
                        }
                        completion(self.postList)
                        
                    }
                    
                    
                }
                
            }
            
        }
        
    }

    
    func downloadDataSaveVCForEdit(postId: String, completion: @escaping (Post) -> Void) {
        
        
        let firestoreDatabase = Firestore.firestore()
               
        firestoreDatabase.collection("posts").whereField("postId", isEqualTo: "\(postId)").addSnapshotListener { snapshot, error in
            
            if error != nil{
                
                print(error?.localizedDescription ?? "error")
            }else {
                
                if snapshot?.isEmpty != true && snapshot != nil {
                    
                    DispatchQueue.global().async {
                        
                        for document in snapshot!.documents {
                            
                            if let postId = document.get("postId") as? String {
                                self.post.postId = postId
                            }
                            
                            if let imageUrl = document.get("imageUrl") as? String {
                                self.post.postImageUrl = imageUrl
                            }
                            
                            if let iconUrl = document.get("userIconUrl") as? String {
                                self.post.userIconUrl = iconUrl
                            }
                            
                            if let postedBy = document.get("postedBy") as? String {
                                self.post.postedBy = postedBy
                            }
                            
                            if let postMovieName = document.get("postMovieName") as? String {
                                self.post.postMovieName = postMovieName
                            }
                            
                            if let postMovieYear = document.get("postMovieYear") as? String {
                                self.post.postMovieYear = postMovieYear
                            }
                            
                            if let postMovieDirector = document.get("postDirector") as? String {
                                self.post.postMovieDirector = postMovieDirector
                            }
                            
                            if let postMovieComment = document.get("postComment") as? String {
                                self.post.postMovieComment = postMovieComment
                            }
                            
                            if let postDate = document.get("date") as? String {
                                self.post.postDate = postDate
                            }
                            
                        }
                        completion(self.post)
                    }
                    
                }
            }
        }
        
    }
    
    
    func downloadDataFollowingVC(completion: @escaping ([Post]) -> Void ) {
           
        //self.postList.removeAll(keepingCapacity: false)
                
        guard let cuid = Auth.auth().currentUser?.uid as? String else {return}
        
        let firestoreDatabase = Firestore.firestore()
        
        firestoreDatabase.collection("following").document(cuid).addSnapshotListener { snapshot, error in
                        
            if error != nil {
                
                print(error?.localizedDescription ?? "error")
                
            }else {
                
                if snapshot != nil && snapshot?.exists == true {
                    
                    guard let userIdsDictionary = snapshot?.data() as? [String : Int] else { return }
                    
                    self.postList.removeAll(keepingCapacity: false)
                    
                    userIdsDictionary.forEach { (key, value) in
                       
                        if key != "" && key.isEmpty != true && userIdsDictionary.isEmpty != true {
                            
                            self.getUsername(uid: key) { usName in
                                
                                firestoreDatabase.collection("posts").whereField("postedBy", isEqualTo: "\(usName)").order(by: "date", descending: true).addSnapshotListener { snap, error in
                                    
                                    if error != nil{
                                        
                                        print(error?.localizedDescription ?? "error")
                                    }else {
                                        
                                        if snap?.isEmpty != true && snap != nil {
                                            
                                            DispatchQueue.global().async {
                                                
                                                for document in snap!.documents {
                                                    
                                                    if let postId = document.get("postId") as? String {
                                                        self.post.postId = postId
                                                    }
                                                    
                                                    if let iconUrl = document.get("userIconUrl") as? String {
                                                        self.post.userIconUrl = iconUrl
                                                    }
                                                    
                                                    if let postedBy = document.get("postedBy") as? String {
                                                        self.post.postedBy = postedBy
                                                    }
                                                    
                                                    if let postMovieName = document.get("postMovieName") as? String {
                                                        self.post.postMovieName = postMovieName
                                                    }
                                                    
                                                    if let postMovieYear = document.get("postMovieYear") as? String {
                                                        self.post.postMovieYear = postMovieYear
                                                    }
                                                    
                                                    if let postMovieDirector = document.get("postDirector") as? String {
                                                        self.post.postMovieDirector = postMovieDirector
                                                    }
                                                    
                                                    if let postMovieComment = document.get("postComment") as? String {
                                                        self.post.postMovieComment = postMovieComment
                                                    }
                                                    
                                                    if let postDate = document.get("date") as? String {
                                                        self.post.postDate = postDate
                                                    }
                                                    
                                                    self.postList.append(self.post)
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                    completion(self.postList)
                                }
                                
                            }
                            
                        }
                        
                    }
                        
                    print("\nuserdictionay foreach e girmedik\n")
                    completion(self.postList)
                }
                
            }
            
        }
        
    }
    
    func getUsername(uid : String, completion: @escaping (String) -> Void) {
                
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("users").document(uid).getDocument { document, error in
            
            if error != nil{
                
                print("error: \(String(describing: error?.localizedDescription))")
                
            }else {
                
                if let document = document, document.exists {
                    
                    if let usernameData = document.get("username") as? String{
            
                        completion(usernameData)
                        
                    } else {
                        print("document field was not gotten")
                    }
                }
                
            }
            
        }
        
    }
    

    
}



