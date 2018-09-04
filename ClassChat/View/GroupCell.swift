//
//  GroupCell.swift
//  ClassChat
//
//  Created by Stephen Link on 8/13/18.
//  Copyright © 2018 Stephen Link. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {

    @IBOutlet weak var groupImageView: UIImageView!
    
    //I used labels instead of text views here since this text will not be editable by the user
    @IBOutlet weak var groupTitleLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
