//
//  WebService.swift
//  overlokfilm2
//
//  Created by hyasar on 7.11.2022.
//

import Foundation
import Firebase
import SDWebImage

class WebService {
    
    var post = Post()
    var postList = [Post]()
    
    var movie = Movie()
    var movieList = [Movie]()
    
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
    
    
    
    func downloadDataUserMovies(completion: @escaping ([Movie]) -> Void){
        
        let firestoreDatabase = Firestore.firestore()
               
        firestoreDatabase.collection("posts").whereField("postedBy", isEqualTo: "\(self.username)").order(by: "date", descending: false) .addSnapshotListener { snapshot, error in
            
            if error != nil{
                print(error?.localizedDescription ?? "error")
                
            }else{
                
                if snapshot?.isEmpty != true && snapshot != nil {
                    
                    self.movieList.removeAll(keepingCapacity: false)
                    
                    DispatchQueue.global().async {
                        
                        for document in snapshot!.documents {
                            
                            if let postedBy = document.get("postedBy") as? String {
                                self.post.postedBy = postedBy
                            }
                            
                            if let postDate = document.get("date") as? String {
                                self.post.postDate = postDate
                            }
                            
                            if let movieName = document.get("postMovieName") as? String {
                                self.movie.movieName = movieName
                            }
                       
                            if let movieYear = document.get("postMovieYear") as? String {
                                self.movie.movieYear = movieYear
                            }
                            
                            if let movieDirector = document.get("postDirector") as? String {
                                self.movie.movieDirector = movieDirector
                            }
                            
                            if let movieComment = document.get("postComment") as? String {
                                self.movie.movieComment = movieComment
                            }
                            
                            self.movieList.append(self.movie)
                            
                        }
                        completion(self.movieList)
                        
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



