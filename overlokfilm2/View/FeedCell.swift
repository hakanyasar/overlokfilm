//
//  FeedCell.swift
//  overlokfilm2
//
//  Created by hyasar on 7.11.2022.
//

import UIKit


protocol FeedButtonsDelegate : AnyObject {
    
    func likeButtonDidTap(cell : FeedCell)
    func watchListButtonDidTap(cell : FeedCell)
    func threeDotMenuButtonDidTap(cell : FeedCell)
    
}

class FeedCell: UITableViewCell {
 
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
    
    weak var delegate : FeedButtonsDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        userImage.layer.cornerRadius = userImage.frame.size.height/2
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
        
        delegate?.threeDotMenuButtonDidTap(cell : self)
    }
    

}
