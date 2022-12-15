//
//  PostDetailViewController.swift
//  overlokfilm2
//
//  Created by hyasar on 7.11.2022.
//

import Foundation
import UIKit
import Firebase
import SDWebImage

class PostDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var detailTableView: UITableView!
    
    private var postDetailViewModel : PostDetailViewModel!
    var webService = WebService()
    
    var postId = ""
        
    override func viewDidLoad() {
        super.viewDidLoad()

        detailTableView.delegate = self
        detailTableView.dataSource = self
            
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        getData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.postDetailViewModel == nil ? 0 : self.postDetailViewModel.numberOfRowsInSection()
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = detailTableView.dequeueReusableCell(withIdentifier: "detailOfCell", for: indexPath) as! DetailCell
        
        let postViewModel = self.postDetailViewModel.postAtIndex(index: indexPath.row)
                
        // image a placeholder ekle
        cell.postImageView.sd_setImage(with: URL(string: postViewModel.postImageUrl))
        cell.movieNameLabel.text = "\(postViewModel.postMovieName)" + " (\(postViewModel.postMovieYear))"
        cell.directorNameLabel.text = postViewModel.postMovieDirector
        cell.commentLabel.text = postViewModel.postMovieComment
        cell.dateLabel.text = postViewModel.postDate
        cell.usernameLabel.text = postViewModel.postedBy
        cell.userImage.sd_setImage(with: URL(string: postViewModel.userIconUrl))
        
        return cell
        
    }
    
    func getData(){
        
        if postId != "" {
            
            webService.downloadDataDetailPostVC(postID: postId){ postList in
                
                self.postDetailViewModel = PostDetailViewModel(postList: postList)
                
                DispatchQueue.main.async {
                    self.detailTableView.reloadData()
                }
                
            }
            
        }else{
            makeAlert(titleInput: "error", messageInput: "\nsorry! post wasn't found. try again later.")
        }
        
    }
    
    func makeAlert(titleInput: String, messageInput: String){
        
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
}

