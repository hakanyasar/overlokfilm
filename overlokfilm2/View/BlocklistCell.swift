//
//  BlocklistCell.swift
//  overlokfilm2
//
//  Created by hyasar on 13.03.2023.
//

import UIKit

class BlocklistCell: UITableViewCell {

    
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func removeButtonClicked(_ sender: Any) {
        
        
    }
    
}
