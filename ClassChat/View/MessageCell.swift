//
//  MessageCell.swift
//  ClassChat
//
//  Created by Stephen Link on 9/2/18.
//  Copyright © 2018 Stephen Link. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.circular()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
