//
//  FeedCell.swift
//  overlokfilm2
//
//  Created by hyasar on 7.11.2022.
//

import UIKit

class FeedCell: UITableViewCell {

 
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var directorNameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var watchListButton: UIButton!
    @IBOutlet weak var threeDotMenuButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        
        
    }
    
    @IBAction func commentButtonClicked(_ sender: Any) {
        
        
    }
    
    
    @IBAction func threeDotMenuButtonClicked(_ sender: Any) {
        
        
    }
    
  
    @IBAction func watchListButtonClicked(_ sender: Any) {
    }
    
    

}
