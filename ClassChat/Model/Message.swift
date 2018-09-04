//
//  Message.swift
//  ClassChat
//
//  Created by Stephen Link on 9/2/18.
//  Copyright © 2018 Stephen Link. All rights reserved.
//

import Foundation

struct Message {
    var sender : String
    var message : String
    var timestamp : Double
    var profileImageURL : String
    
    init(sender: String, message: String, timestamp: Double, profileImageURL: String) {
        self.sender = sender
        self.message = message
        self.timestamp = timestamp
        self.profileImageURL = profileImageURL
    }
}
