//
//  MyUser.swift
//  ClassChat
//
//  Created by Stephen Link on 8/5/18.
//  Copyright © 2018 Stephen Link. All rights reserved.
//

import Foundation

class MyUser: NSObject {
    var email: String
    var password: String
    var username: String
    var uid: String
    var groups: Dictionary<String,String>
    
    init(email: String, password: String, uid: String, username: String, groups: Dictionary<String,String>) {
        self.email = email
        self.password = password
        self.uid = uid
        self.username = username
        self.groups = groups
    }
    
    convenience override init() {
        self.init(email: "what", password: "how", uid: "aye", username: "bruh", groups: Dictionary<String,String>())
    }
}
