//
//  WebService.swift
//  overlokfilm2
//
//  Created by hyasar on 7.11.2022.
//

import Foundation
import Firebase

class WebService {
    
    // MARK: - variables
    
    var post = Post()
    var user = User()
    var postList = [Post]()
    var postListForFollowingPosts = [Post]()
    
    let group = DispatchGroup()
    var userNamesDictFollowingVC : [String] = []
    
    let queue = OperationQueue()
    
    // MARK: - Feed
    
    func downloadData(completion: @escaping ([Post]) -> Void ){
        
        // download data with pagination way
        
        let firestoreDatabase = Firestore.firestore()
        
        let firstPage = firestoreDatabase.collection("posts").order(by: "date", descending: true).limit(to: FeedPaginationSingletonModel.sharedInstance.postSize)
        
        firstPage.getDocuments(source: .server) { snapshot, error in
            
            if let error = error {
                
                print("Error getting documents: \(error)")
            } else {
                
                self.postList.removeAll(keepingCapacity: false)
                
                FeedPaginationSingletonModel.sharedInstance.lastPost = snapshot!.documents.last
                
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
                        
                        if let postIsLiked = document.get("isLiked") as? Bool {
                            self.post.isLiked = postIsLiked
                        }
                        
                        if let postWatchlistedCount = document.get("watchlistedCount") as? Int {
                            self.post.postWatchlistedCount = postWatchlistedCount
                        }
                        
                        self.postList.append(self.post)
                        
                    }
                    completion(self.postList)
                    
                }
                
            }
            
        }
        
        
        
        
        
        /*
         
         // normal way
         
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
         */
        
        
    }
    
    
    func continuePagesFeed(completion: @escaping ([Post]) -> Void ){
        
        if FeedPaginationSingletonModel.sharedInstance.lastPost == nil{
            return
        }
        
        let firestoreDatabase = Firestore.firestore()
        
        let nextPage = firestoreDatabase.collection("posts").order(by: "date", descending: true).limit(to: FeedPaginationSingletonModel.sharedInstance.postSize).start(afterDocument: FeedPaginationSingletonModel.sharedInstance.lastPost!)
        
        nextPage.getDocuments { snapshot, error in
            
            if snapshot!.count < FeedPaginationSingletonModel.sharedInstance.postSize {
                
                FeedPaginationSingletonModel.sharedInstance.lastPost = nil
                FeedPaginationSingletonModel.sharedInstance.isFinishedPaging = true
            }
            
            if let error = error {
                
                print("error getting documents: \(error)")
            } else {
                
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
                        
                        if let postWatchlistedCount = document.get("watchlistedCount") as? Int {
                            self.post.postWatchlistedCount = postWatchlistedCount
                        }
                        
                        self.postList.append(self.post)
                        
                    }
                    completion(self.postList)
                    
                    FeedPaginationSingletonModel.sharedInstance.lastPost = snapshot!.documents.last
                    
                }
                
            }
            
        }
        
    }
    
    
    // MARK: - userVC
    
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
                            
                            if let postWatchlistedCount = document.get("watchlistedCount") as? Int {
                                self.post.postWatchlistedCount = postWatchlistedCount
                            }
                            
                            self.postList.append(self.post)
                            
                        }
                        completion(self.postList)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    // MARK: - postDetailVC
    
    func downloadDataDetailPostVC(postID : String, completion: @escaping ([Post]) -> Void){
        
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
                            
                            if let postWatchlistedCount = document.get("watchlistedCount") as? Int {
                                self.post.postWatchlistedCount = postWatchlistedCount
                            }
                            
                            self.postList.append(self.post)
                            
                        }
                        completion(self.postList)
                        
                    }
                    
                    
                }
                
            }
            
        }
        
    }
    
    // MARK: - saveVC (edit)
    
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
                            
                            if let postWatchlistedCount = document.get("watchlistedCount") as? Int {
                                self.post.postWatchlistedCount = postWatchlistedCount
                            }
                            
                        }
                        completion(self.post)
                    }
                    
                }
            }
        }
        
    }
    
    // MARK: - followingVC
    
    func downloadDataFollowingVC(completion: @escaping ([Post]) -> Void) {
        
         print("\n\n\n xx __________________ we are in download data following vc _______________________ \n\n\n")
        
        self.userNamesDictFollowingVC.removeAll(keepingCapacity: false)
        
         guard let cuid = Auth.auth().currentUser?.uid as? String else {return}
         
         let firestoreDatabase = Firestore.firestore()
         
        firestoreDatabase.collection("following").document(cuid).getDocument(source: .server) { document, error in
            
            if let document = document, document.exists {
                
                guard let userIdsDictionary = document.data() as? [String : Int] else {return}
                
                    userIdsDictionary.forEach { (key, value) in
                        
                        print("\n xx 1")
                        self.group.enter()
                        self.getUsername(uid: key) { uName in
                            
                            print("\n xx 2")
                            self.userNamesDictFollowingVC.append(uName)
                            print("\n xx userNamesDictFollowingVC 1: \(self.userNamesDictFollowingVC)")
                            self.group.leave()
                        }
                        
                    }
                
                self.group.notify(queue: .main) {
                    
                    print("\n xx userNamesDictFollowingVC: \(self.userNamesDictFollowingVC)")
                    
                    let group2 = DispatchGroup()
                    
                    self.userNamesDictFollowingVC.forEach { uName in
                        
                        print("\n xx 3")
                        
                        group2.enter()
                        
                        self.postList.removeAll(keepingCapacity: false)
                        
                        self.fetchPosts(username: uName) { postList in

                            print("\n xx 4 postListComeFromFetch: \(postList)")
                            self.postList.append(contentsOf: postList)
                            print("\n xx postlist after append: \(self.postList)")
                            
                            group2.leave()
                        }
                        
                    }
                    
                    group2.notify(queue: .main) {
                        
                        print("\n xx before comp postList: \(self.postList)")
                        completion(self.postList)
                    }
                    
                }
               
            }
            
        }
        
        
        /*
         
         
         
         self.group.notify(queue: .global(), execute: {
         
         print("\nxx userNamesDictFollowingVC: \(self.userNamesDictFollowingVC)")
         
         
         self.userNamesDictFollowingVC.forEach { uName in
         
         print("\nxx 2")
         
         let firestoreDatabase = Firestore.firestore()
         
         let firstPage = firestoreDatabase.collection("posts").whereField("postedBy", isEqualTo: "\(uName)").limit(to: FollowingPaginationSingletonModel.sharedInstance.postSize)
         
         firstPage.getDocuments(source: .server) { querySnapshot, error in
         
         print("\nxx 3")
         
         if let error = error {
         
         print("\nerror getting documents: \(error)")
         } else {
         
         FollowingPaginationSingletonModel.sharedInstance.lastPost = querySnapshot!.documents.last
         
         self.postList.removeAll(keepingCapacity: false)
         
         DispatchQueue.global().async {
         
         for document in querySnapshot!.documents {
         
         print("\nxx 4")
         
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
         
         if let postWatchlistedCount = document.get("watchlistedCount") as? Int {
         self.post.postWatchlistedCount = postWatchlistedCount
         }
         
         self.postList.append(self.post)
         }
         
         print("xx 5")
         print("xx before comp folloving vc: \(self.postList)")
         completion(self.postList)
         
         }
         }
         
         }
         
         }
         
         })
         
         
        
        
        
        
    } else {
        print("Document does not exist")
    }
    
}

*/
         
         
         

/*
 
 // tek completion ı pagination ile beraber deniyoruz burada. "in" query ile 10 tane data kontrolü yapılabiliyor. bu da user, max 10 kisiyi takip edebilir demek. bi ise yaramaz "in" query
 
 self.postList.removeAll(keepingCapacity: false)
 
 guard let cuid = Auth.auth().currentUser?.uid as? String else {return}
 
 let firestoreDatabase = Firestore.firestore()
 
 firestoreDatabase.collection("following").document(cuid).getDocument(source: .server) { document, error in
 
 if let document = document, document.exists {
 
 guard let userIdsDictionary = document.data() as? [String : Int] else {return}
 
 userIdsDictionary.forEach { (key, value) in
 
 self.group.enter()
 self.getUsername(uid: key) { uName in
 
 self.userNamesDictFollowingVC.append(uName)
 
 self.group.leave()
 }
 
 }
 
 
 self.group.notify(queue: .main, execute: {
 
 let firestoreDatabase = Firestore.firestore()
 
 let firstPage = firestoreDatabase.collection("posts").whereField("postedBy", in: self.userNamesDictFollowingVC).limit(to: FollowingPaginationSingletonModel.sharedInstance.postSize)
 
 firstPage.getDocuments(source: .server) { querySnapshot, error in
 
 if let error = error {
 
 print("\nerror getting documents: \(error)")
 } else {
 
 FollowingPaginationSingletonModel.sharedInstance.lastPost = querySnapshot!.documents.last
 
 DispatchQueue.global().async {
 
 for document in querySnapshot!.documents {
 
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
 
 if let postWatchlistedCount = document.get("watchlistedCount") as? Int {
 self.post.postWatchlistedCount = postWatchlistedCount
 }
 
 self.postList.append(self.post)
 }
 
 print("xx before comp folloving vc: \(self.postList)")
 completion(self.postList)
 }
 
 }
 
 }
 })
 
 
 
 } else {
 print("Document does not exist")
 }
 
 }
 
 */

        
        
        

/*

        
        
// ilk denedigim yontem bu. dispatch group denemek icin bıraktım bu yontemi. (bu dogru sonuc veriyor ama, birden fazla kez completion gönderiyor.)

self.postList.removeAll(keepingCapacity: false)

guard let cuid = Auth.auth().currentUser?.uid as? String else {return}

let firestoreDatabase = Firestore.firestore()

firestoreDatabase.collection("following").document(cuid).addSnapshotListener { snapshot, error in
    
    if error != nil {
        
        print(error?.localizedDescription ?? "error")
        
    }else {
        
        if snapshot != nil && snapshot?.exists == true {
            
            guard let userIdsDictionary = snapshot?.data() as? [String : Int] else { return }
            
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
                                            
                                            if let postWatchlistedCount = document.get("watchlistedCount") as? Int {
                                                self.post.postWatchlistedCount = postWatchlistedCount
                                            }
                                            
                                            self.postList.append(self.post)
                                        }
                                        completion(self.postList)
                                        
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

        */

}


func fetchPosts(username: String, completion: @escaping ([Post]) -> Void) {
    
    print("\n xx fetchposts")
    
    let firestoreDatabase = Firestore.firestore()
    
    let firstPage = firestoreDatabase.collection("posts").whereField("postedBy", isEqualTo: "\(username)")
    
    firstPage.getDocuments(source: .server) { querySnapshot, error in
        
        if let error = error {
            
            print("\nerror getting documents: \(error)")
        } else {
            
            //FollowingPaginationSingletonModel.sharedInstance.lastPost = querySnapshot!.documents.last
            
            self.postListForFollowingPosts.removeAll(keepingCapacity: false)
            
            //DispatchQueue.global().async {
                
                for document in querySnapshot!.documents {
                    
                    print("\nxx fetch posts for document loop")
                    
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
                    
                    if let postWatchlistedCount = document.get("watchlistedCount") as? Int {
                        self.post.postWatchlistedCount = postWatchlistedCount
                    }
                    
                    self.postListForFollowingPosts.append(self.post)
                }
                
                print("\n xx fetch posts before completion")
                completion(self.postListForFollowingPosts)
                
            //}
        }
        
    }
    
}


func continuePagesFollowing(completion: @escaping ([Post]) -> Void ) {
    
    print("xx we are in continue pages folloving")
    
    // tek completion yapıyor ama 10 tane veri getirebiliyor ancak. pagination ile kullanılırsa işe yarayabilir.
    
    self.postList.removeAll(keepingCapacity: false)
    //self.userNamesDictFollowingVC.removeAll(keepingCapacity: false)
    
    guard let cuid = Auth.auth().currentUser?.uid as? String else {return}
    
    let firestoreDatabase = Firestore.firestore()
    
    firestoreDatabase.collection("following").document(cuid).getDocument(source: .server) { document, error in
        
        if let document = document, document.exists {
            
            guard let userIdsDictionary = document.data() as? [String : Int] else {return}
            
            userIdsDictionary.forEach { (key, value) in
                
                self.group.enter()
                self.getUsername(uid: key) { uName in
                    
                    self.userNamesDictFollowingVC.append(uName)
                    
                    self.group.leave()
                }
                
            }
            
            self.group.notify(queue: .main, execute: {
                
                print("\n xx usernamesdictfollowingVC: \(self.userNamesDictFollowingVC)")
                
                if FollowingPaginationSingletonModel.sharedInstance.lastPost == nil{
                    return
                }
                
                let firestoreDatabase = Firestore.firestore()
                
                let userNamesDictArrayFollowingVC : [String] = Array(self.userNamesDictFollowingVC)
                                
                let nextPage = firestoreDatabase.collection("posts").whereField("postedBy", in: userNamesDictArrayFollowingVC).order(by: "date", descending: true).limit(to: FollowingPaginationSingletonModel.sharedInstance.postSize).start(afterDocument: FollowingPaginationSingletonModel.sharedInstance.lastPost!)
                
                nextPage.getDocuments(source: .server) { querySnapshot, error in
                    
                    
                    if querySnapshot!.count < FollowingPaginationSingletonModel.sharedInstance.postSize {
                        
                        FollowingPaginationSingletonModel.sharedInstance.lastPost = nil
                        FollowingPaginationSingletonModel.sharedInstance.isFinishedPaging = true
                    }
                    
                    if let error = error {
                        
                        print("\nerror getting documents: \(error)")
                    } else {
                        
                        DispatchQueue.global().async {
                            
                            for document in querySnapshot!.documents {
                                
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
                                
                                if let postWatchlistedCount = document.get("watchlistedCount") as? Int {
                                    self.post.postWatchlistedCount = postWatchlistedCount
                                }
                                
                                self.postList.append(self.post)
                            }
                            
                            completion(self.postList)
                            FollowingPaginationSingletonModel.sharedInstance.lastPost = querySnapshot!.documents.last
                        }
                        
                    }
                    
                }
            })
            
        } else {
            print("Document does not exist")
        }
        
    }
    
}




// MARK: - userVC (userFields)

func downloadDataForUserFields(username : String, completion: @escaping (User) -> Void) {
    
    
    // ikinci yontem getdocuments ile
    
    let firestoreDatabase = Firestore.firestore()
    
    firestoreDatabase.collection("users").whereField("username", isEqualTo: username).getDocuments(source: .server) { querySnapshot, error in
        
        if let error = error {
            print("\n error getting documents: \(error)")
        } else {
            
            DispatchQueue.global().async {
                
                for document in querySnapshot!.documents {
                    
                    self.user.userId = String(document.documentID)
                    
                    if let profileImageUrl = document.get("profileImageUrl") as? String {
                        self.user.profileImageUrl = profileImageUrl
                    }
                    
                    if let username = document.get("username") as? String {
                        self.user.username = username
                    }
                    
                    if let email = document.get("email") as? String {
                        self.user.email = email
                    }
                    
                    if let userBio = document.get("bio") as? String {
                        self.user.bio = userBio
                    }
                    
                    if let postCount = document.get("postCount") as? Int {
                        self.user.postCount = postCount
                    }
                    
                    if let followersCount = document.get("followersCount") as? Int {
                        self.user.followersCount = followersCount
                    }
                    
                    if let followingCount = document.get("followingCount") as? Int {
                        self.user.followingCount = followingCount
                    }
                    
                }
                completion(self.user)
            }
            
        }
        
    }
    
}


// MARK: - likesVC

func downloadDataLikesVC(userId : String, completion: @escaping ([Post]) -> Void){
    
    /*
     
     // addsnapshot ile cekiyoruz
     
     self.postList.removeAll(keepingCapacity: false)
     
     let firestoreDb = Firestore.firestore()
     
     firestoreDb.collection("likes").document(userId).addSnapshotListener { docSnapshot, error in
     
     if error != nil {
     
     print(error?.localizedDescription ?? "error")
     }else {
     
     if docSnapshot != nil && docSnapshot?.exists == true  {
     
     guard let postIdsDic = docSnapshot!.data() as? [String : Int] else { return }
     
     postIdsDic.forEach { (key, value) in
     
     if key != "" && key.isEmpty != true && postIdsDic.isEmpty != true {
     
     firestoreDb.collection("posts").whereField("postId", isEqualTo: "\(key)").order(by: "date", descending: true).addSnapshotListener { snap, error in
     
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
     
     if let postWatchlistedCount = document.get("watchlistedCount") as? Int {
     self.post.postWatchlistedCount = postWatchlistedCount
     }
     
     self.postList.append(self.post)
     }
     
     completion(self.postList)
     
     }
     
     }
     
     }
     
     }
     
     }
     
     }
     
     }
     
     }
     
     }
     
     */
    
    
    
    // get document ile cekiyoruz
    
    self.postList.removeAll(keepingCapacity: false)
    
    let firestoreDb = Firestore.firestore()
    
    firestoreDb.collection("likes").document(userId).getDocument { document, error in
        
        if let document = document, document.exists {
            
            guard let postIdsDic = document.data() as? [String : Int] else { return }
            
            postIdsDic.forEach { (key, value) in
                
                if key != "" && key.isEmpty != true && postIdsDic.isEmpty != true {
                    
                    firestoreDb.collection("posts").whereField("postId", isEqualTo: "\(key)").getDocuments(source: .server) { querySnapshot, error in
                        
                        print("*n xx likes foreach key: \(key) \n")
                        
                        if let error = error {
                            
                            print("Error getting documents: \(error)")
                        } else {
                            
                            DispatchQueue.global().async {
                                
                                self.postList.removeAll(keepingCapacity: false)
                                
                                for document in querySnapshot!.documents {
                                    
                                    print("\n xx downloadDataLikesVC da for document a girdik \n")
                                    
                                    if let postId = document.get("postId") as? String {
                                        self.post.postId = postId
                                    }
                                    
                                    if let postMovieName = document.get("postMovieName") as? String {
                                        self.post.postMovieName = postMovieName
                                    }
                                    
                                    if let postedBy = document.get("postedBy") as? String {
                                        self.post.postedBy = postedBy
                                    }
                                    
                                    if let postMovieYear = document.get("postMovieYear") as? String {
                                        self.post.postMovieYear = postMovieYear
                                    }
                                    
                                    if let iconUrl = document.get("userIconUrl") as? String {
                                        self.post.userIconUrl = iconUrl
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
                                
                                print("\n xx likes before comp: \(self.postList)")
                                completion(self.postList)
                                
                            }
                        }
                    }
                    
                }
                
            }
            
        }else {
            
            print("Document does not exist")
        }
        
    }
    
}

// MARK: - watchlistsVC

func downloadDataWatchlistsVC(userId : String, completion: @escaping ([Post]) -> Void){
    
    self.postList.removeAll(keepingCapacity: false)
    
    let firestoreDb = Firestore.firestore()
    
    firestoreDb.collection("watchlists").document(userId).addSnapshotListener { docSnapshot, error in
        
        if error != nil {
            
            print(error?.localizedDescription ?? "error")
        }else {
            
            if docSnapshot != nil && docSnapshot?.exists == true  {
                
                guard let postIdsDic = docSnapshot!.data() as? [String : Int] else { return }
                
                postIdsDic.forEach { (key, value) in
                    
                    if key != "" && key.isEmpty != true && postIdsDic.isEmpty != true {
                        
                        firestoreDb.collection("posts").whereField("postId", isEqualTo: "\(key)").order(by: "date", descending: true).addSnapshotListener { snap, error in
                            
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
                                            
                                            if let postWatchlistedCount = document.get("watchlistedCount") as? Int {
                                                self.post.postWatchlistedCount = postWatchlistedCount
                                            }
                                            
                                            self.postList.append(self.post)
                                        }
                                        
                                        completion(self.postList)
                                        
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
    
    // MARK: - blocklistVC
    
    func downloadDataBlocklistVC(userId : String, completion: @escaping ([String]) -> Void){
        
        var userList : [String] = []
        
        let serialQueue = DispatchQueue.main
        
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("blocking").document(userId).getDocument(source: .server) { document, error in
                
                if let document = document, document.exists {
                    
                    guard let userIdsDic = document.data() as? [String : Int] else { return }
                    
                        print("xx 1")
                        userIdsDic.forEach{ (key, value) in
                            
                            if key != "" && key.isEmpty != true && userIdsDic.isEmpty != true{
                                
                                self.group.enter()
                                self.getUsername(uid: key) { username in
                                    print("xx 2")
                                    userList.append(username)
                                    self.group.leave()
                                }
                            }
                        }
                    
                    self.group.notify(queue: .main){
                        print("xx 3")
                        
                        let group2 = DispatchGroup()
                        
                        completion(userList)
                        print(userList)
                    }
                    
                }else{
                    print("\ndocument does not exist.")
                }
        }
    }


// MARK: - the other functions

func getUsername(uid : String, completion: @escaping (String) -> Void) {
    
    let firestoreDb = Firestore.firestore()
    
    firestoreDb.collection("users").document(uid).getDocument(source: .server) { document, error in
        
        if error != nil{
            
            print("error: \(String(describing: error?.localizedDescription))")
            
        }else {
            
            if let document = document, document.exists {
                
                //DispatchQueue.global().async {
                    
                    if let usernameData = document.get("username") as? String{
                        
                        completion(usernameData)
                        
                    } else {
                        print("\n document field was not gotten")
                    }
                    
                //}
                
            }
            
        }
        
    }
}



func getUserId(uName: String, completion: @escaping (String) -> Void) {
    
    let firestoreDb = Firestore.firestore()
    
    firestoreDb.collection("users").whereField("username", isEqualTo: uName).getDocuments(source: .server) { snapshot, error in
        
        if error != nil {
            
            print(error?.localizedDescription ?? "error")
        }else {
            
            for document in snapshot!.documents {
                
                let userId = document.documentID
                completion(userId)
            }
            
        }
        
    }
    
}


}


