//
//  GroupInfo.swift
//  ClassChat
//
//  Created by Stephen Link on 8/25/18.
//  Copyright © 2018 Stephen Link. All rights reserved.
//

import Foundation

struct GroupInfo {
    var id : String
    var title : String
    var lastMessage : String
    var timestamp : Double
    var groupImageURL : String
    
    init(id: String, title: String, lastMessage: String, timestamp: Double, groupImageURL: String) {
        self.id = id
        self.title = title
        self.lastMessage = lastMessage
        self.timestamp = timestamp
        self.groupImageURL = groupImageURL
    }
}
