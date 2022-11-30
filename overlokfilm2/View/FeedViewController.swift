//
//  FeedViewController.swift
//  overlokfilm2
//
//  Created by hyasar on 7.11.2022.
//

import Foundation
import Firebase
import UIKit


class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    private var feedViewModel : FeedViewModel!
    var webService = WebService()
    var feedVSM = FeedViewSingletonModel.sharedInstance
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getData()
        
        //page refresh
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
    }
  
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.feedViewModel == nil ? 0 : self.feedViewModel.numberOfRowsInSection()
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellOfFeed", for: indexPath) as! FeedCell
        
        let postViewModel = self.feedViewModel.postAtIndex(index: indexPath.row)
        
        cell.movieNameLabel.text = "\(postViewModel.postMovieName)" + " (\(postViewModel.postMovieYear))"
        cell.directorNameLabel.text = postViewModel.postMovieDirector
        cell.commentLabel.text = postViewModel.postMovieComment
        cell.dateLabel.text = postViewModel.postDate
        cell.usernameLabel.text = postViewModel.postedBy
   
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let postViewModel = self.feedViewModel.postAtIndex(index: indexPath.row)
                
        feedVSM = FeedViewSingletonModel.sharedInstance
        
        feedVSM.postId = postViewModel.postId
                
        performSegue(withIdentifier: "toPostDetailVCFromFeed", sender: indexPath)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toPostDetailVCFromFeed" {
            
            let destinationVC = segue.destination as! PostDetailViewController
            
            destinationVC.postId = feedVSM.postId
            
        }
        
    }
    
    func getData() {
        
        webService.downloadData { postList in
                
            self.feedViewModel = FeedViewModel(postList: postList)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }

    
    
    @objc private func didPullToRefresh(){
        
        getData()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
}


