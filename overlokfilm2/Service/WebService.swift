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
    
    var username = "overlokcu"
    
    init(){
        getUsername()
    }
    
    
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
    
    
    
    func downloadDataUserMovies(completion: @escaping ([Post]) -> Void){
        
        let firestoreDatabase = Firestore.firestore()
               
        firestoreDatabase.collection("posts").whereField("postedBy", isEqualTo: "\(self.username)").order(by: "date", descending: false).addSnapshotListener { snapshot, error in
            
            if error != nil{
                print(error?.localizedDescription ?? "error")
                
            }else{
                
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
    
    
    func downloadDataDetailPost(postID : String, completion: @escaping ([Post]) -> Void){
        
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
    
    
    func getUsername() {
        
        let cuid = Auth.auth().currentUser?.uid as? String
        
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("users").document(cuid!).getDocument { document, error in
            
            if error != nil{
                print(error?.localizedDescription ?? "error")
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
    
}



