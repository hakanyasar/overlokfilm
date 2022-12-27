//
//  FollowingFeedCell.swift
//  overlokfilm2
//
//  Created by hyasar on 26.11.2022.
//

import UIKit

protocol FollowingFeedCellDelegate : AnyObject {
    
    func likeButtonDidTap(cell : FollowingFeedCell)
    func watchListButtonDidTap(cell : FollowingFeedCell)
    func threeDotMenuButtonDidTap(cell : FollowingFeedCell)
    
}

class FollowingFeedCell: UITableViewCell {
    
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var directorNameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var watchListButton: UIButton!
    @IBOutlet weak var watchListCountLabel: UILabel!
    @IBOutlet weak var threeDotMenuButton: UIButton!
    
    weak var delegate : FollowingFeedCellDelegate?
    var postId = ""
    
    var isLikedCheck = Bool()
    var isWatchlistedCheck = Bool()

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        userImage.isUserInteractionEnabled = true
        
        userImage.layer.cornerRadius = userImage.frame.size.height/2
        
        userImage.contentMode = .scaleAspectFill
        userImage.clipsToBounds = true  // what does this do?
        
        userImage.layer.masksToBounds = true
        userImage.layer.borderColor = UIColor.gray.cgColor
        userImage.layer.borderWidth = 1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        
        delegate?.likeButtonDidTap(cell : self)
    }
    
    
    @IBAction func watchListButtonClicked(_ sender: Any) {
        
        delegate?.watchListButtonDidTap(cell : self)
    }
    
    
    @IBAction func threeDotMenuButtonClicked(_ sender: Any) {
        
        delegate?.threeDotMenuButtonDidTap(cell: self)
    }
    

}
