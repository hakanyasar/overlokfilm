//
//  FollowingViewController.swift
//  overlokfilm2
//
//  Created by hyasar on 7.11.2022.
//

import UIKit

class FollowingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    
    @IBOutlet weak var followingTableView: UITableView!
    
    private var followingViewModel : FollowingViewModel!
    var webService = WebService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getData()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return self.followingViewModel == nil ? 0 : self.followingViewModel.numberOfRowsInSection()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = followingTableView.dequeueReusableCell(withIdentifier: "cellOfFollowing", for: indexPath) as! FollowingFeedCell
        
        let postViewModel = self.followingViewModel.postAtIndex(index: indexPath.row)
        
        cell.movieNameLabel.text = "\(postViewModel.postMovieName)" + " (\(postViewModel.postMovieYear))"
        cell.directorNameLabel.text = postViewModel.postMovieDirector
        cell.commentLabel.text = postViewModel.postMovieComment
        cell.dateLabel.text = postViewModel.postDate
        cell.usernameLabel.text = postViewModel.postedBy
        
        return cell
        
    }
    
    func getData(){
        
        
        
        
    }
    

}
