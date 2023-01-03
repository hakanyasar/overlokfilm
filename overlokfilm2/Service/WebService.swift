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
    
    let group = DispatchGroup()
    //var userNamesDict : [String] = []
    
    // MARK: - Feed
    
    func downloadData(completion: @escaping ([Post]) -> Void ){
        
        // download data with pagination way
        
        let firestoreDatabase = Firestore.firestore()
        
        let firstPage = firestoreDatabase.collection("posts").order(by: "date", descending: true).limit(to: PaginationSingletonModel.sharedInstance.postSize)
        
        firstPage.getDocuments(source: .server) { snapshot, error in
            
            if let error = error {
                
                print("Error getting documents: \(error)")
            } else {
                
                self.postList.removeAll(keepingCapacity: false)
                
                PaginationSingletonModel.sharedInstance.lastPost = snapshot!.documents.last
                
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
    
    
    func continuePages(completion: @escaping ([Post]) -> Void ){
        
        // 2. yontem benim denedigim
        
        if PaginationSingletonModel.sharedInstance.lastPost == nil{
            return
        }
        
        let firestoreDatabase = Firestore.firestore()
        
        let nextPage = firestoreDatabase.collection("posts").order(by: "date", descending: true).limit(to: PaginationSingletonModel.sharedInstance.postSize).start(afterDocument: PaginationSingletonModel.sharedInstance.lastPost!)
        
        nextPage.getDocuments { snapshot, error in
            
            if snapshot!.count < PaginationSingletonModel.sharedInstance.postSize {
                
                PaginationSingletonModel.sharedInstance.lastPost = nil
                PaginationSingletonModel.sharedInstance.isFinishedPaging = true
                print("xx pagination = nil")
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
                    
                    PaginationSingletonModel.sharedInstance.lastPost = snapshot!.documents.last
                    print("xx last post: \(PaginationSingletonModel.sharedInstance.lastPost?.documentID)")
                    
                }
                
            }
            
        }
        
        
        
        
        
        
        
        /*
         // 1. yontem stacoverflow reyiz
         
         print("\n continuePages a girdik \n")
         
         guard let cursor = cursor else { return }
         
         let firestoreDatabase = Firestore.firestore()
         
         print("cursor: \(self.cursor)")
         
         let nextPage = firestoreDatabase.collection("posts").order(by: "date", descending: true).limit(to: pageSize).start(afterDocument: cursor)
         
         nextPage.getDocuments { snapshot, error in
         
         print("\n continuePages getDocuments a girdik \n")
         
         guard let snapshot = snapshot else {
         
         completion([])
         if let error = error {
         print(error)
         }
         return
         }
         
         guard !snapshot.isEmpty else {
         // There are no results and so there can be no more
         // results to paginate; nil the cursor.
         self.cursor = nil
         
         completion([])
         return
         }
         
         if snapshot.count < self.pageSize {
         // This snapshot is smaller than a page size and so
         // there can be no more results to paginate; nil
         // the cursor.
         self.cursor = nil
         } else {
         // This snapshot is a full page size and so there
         // could potentially be more results to paginate;
         // set the cursor.
         print("\n self.cursor: \(snapshot.documents.last) \n")
         self.cursor = snapshot.documents.last
         }
         
         
         DispatchQueue.global().async {
         
         for document in snapshot.documents {
         
         print("\n continuePages de for document a girdik \n")
         
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
         print("\n __________ \n")
         //print("\n before completion continuePages: \(self.postList) \n")
         print("\n __________ \n")
         completion(self.postList)
         
         
         }
         
         }
         */
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
        
        /*
         
         // 3. yontem (tek completion yapıyor ama 10 tane veri getirebiliyor ancak. pagination ile kullanılırsa işe yarayabilir.)
         
         self.postList.removeAll(keepingCapacity: false)
         
         guard let cuid = Auth.auth().currentUser?.uid as? String else {return}
         
         let firestoreDatabase = Firestore.firestore()
         
         firestoreDatabase.collection("following").document(cuid).getDocument(source: .server) { document, error in
         
         if let document = document, document.exists {
         
         guard let userIdsDictionary = document.data() as? [String : Int] else {return}
         
         
         userIdsDictionary.forEach { (key, value) in
         
         print("xx userIdDictionary foreach e girdik")
         
         self.group.enter()
         self.getUsername(uid: key) { uName in
         
         print("xx getUsername e girdik")
         self.userNamesDict.append(uName)
         print("xx userNamesDic: \(self.userNamesDict)")
         
         self.group.leave()
         }
         
         }
         
         
         self.group.notify(queue: .main, execute: {
         
         print("xx userDict: \(self.userNamesDict)")
         
         let firestoreDatabase = Firestore.firestore()
         
         firestoreDatabase.collection("posts").whereField("postedBy", in: self.userNamesDict).getDocuments(source: .server) { querySnapshot, error in
         
         if let error = error {
         
         print("\nerror getting documents: \(error)")
         } else {
         
         DispatchQueue.global().async {
         
         for document in querySnapshot!.documents {
         
         print("xx we are in for loop")
         
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
         
         //print("xx before comp: \(self.postList)")
         print("xx \(self.postList)")
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
        
        
        // ikinci yontem
        
        self.postList.removeAll(keepingCapacity: false)
        
        guard let cuid = Auth.auth().currentUser?.uid as? String else {return}
        
        let firestoreDatabase = Firestore.firestore()
        
        firestoreDatabase.collection("following").document(cuid).getDocument(source: .server) { document, error in
            
            if let document = document, document.exists {
                
                self.postList.removeAll(keepingCapacity: false)
                
                guard let userIdsDictionary = document.data() as? [String : Int] else {return}
                
                userIdsDictionary.forEach { (key, value) in
                    
                    self.getUsername(uid: key) { uName in
                        
                        let firestoreDatabase = Firestore.firestore()
                        
                        firestoreDatabase.collection("posts").whereField("postedBy", isEqualTo: "\(uName)").getDocuments(source: .server) { querySnapshot, error in
                            
                            if let error = error {
                                
                                print("\nerror getting documents: \(error)")
                            } else {
                                
                                DispatchQueue.global().async {
                                    
                                    for document in querySnapshot!.documents {
                                        
                                        print("xx we are in for loop")
                                        
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
                                    
                                    //print("xx before comp: \(self.postList)")
                                    print("xx \(self.postList)")
                                    completion(self.postList)
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            } else {
                print("Document does not exist")
            }
            
        }
        
        */
        
        
        
        
        
        
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
        
        
        /*
         
         // ilk yöntem buydu ama butonlara vs tıkladigimda db de her degisiklik oldugunda yeniden request attigi icin bunun yerine getdocument deneyecegim.
         
         let firestoreDatabase = Firestore.firestore()
         
         firestoreDatabase.collection("users").whereField("username", isEqualTo: username).addSnapshotListener { snapshot, error in
         
         if error != nil {
         
         print(error?.localizedDescription ?? "error")
         
         }else {
         
         if snapshot?.isEmpty != true && snapshot != nil {
         
         DispatchQueue.global().async {
         
         for document in snapshot!.documents {
         
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
         */
        
    }
    
    
    // MARK: - likesVC
    
    func downloadDataLikesVC(userId : String, completion: @escaping ([Post]) -> Void){
        
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
        
        
        
        
        
        /*
         
         // get document ile cekiyoruz
         
         let firestoreDb = Firestore.firestore()
         
         firestoreDb.collection("likes").document(userId).getDocument { document, error in
         
         if let document = document, document.exists {
         
         guard let postIdsDic = document.data() as? [String : Int] else { return }
         
         postIdsDic.forEach { (key, value) in
         
         if key != "" && key.isEmpty != true && postIdsDic.isEmpty != true {
         
         firestoreDb.collection("posts").whereField("postId", isEqualTo: "\(key)").getDocuments(source: .server) { querySnapshot, error in
         
         if let error = error {
         
         print("Error getting documents: \(error)")
         } else {
         
         self.postList.removeAll(keepingCapacity: false)
         
         DispatchQueue.global().async {
         
         for document in querySnapshot!.documents {
         
         print("\n downloadDataLikesVC da for document a girdik \n")
         
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
         
         }else {
         
         print("Document does not exist")
         }
         
         }
         */
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
    
    
    // MARK: - the other functions
    
    func getUsername(uid : String, completion: @escaping (String) -> Void) {
        
        let firestoreDb = Firestore.firestore()
        
        firestoreDb.collection("users").document(uid).getDocument(source: .server) { document, error in
            
            if error != nil{
                
                print("error: \(String(describing: error?.localizedDescription))")
                
            }else {
                
                if let document = document, document.exists {
                    
                    DispatchQueue.global().async {
                        
                        if let usernameData = document.get("username") as? String{
                            
                            completion(usernameData)
                            
                        } else {
                            print("\n document field was not gotten")
                        }
                        
                    }
                    
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











/*
 
 
 guard let userIdsDictionary = document.data() as? [String : Int] else {return}
 
 userIdsDictionary.forEach { (key, value) in
 
 print("xx userIdDictionary foreach e girdik")
 
 self.getUsername(uid: key) { uName in
 
 print("xx getUsername e girdik")
 self.userNamesDict.append(uName)
 print("xx userNamesDic: \(self.userNamesDict)")
 }
 }
 
 
 
 
 */
