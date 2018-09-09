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
    var username: String
    var uid: String
    var groups: Dictionary<String,String>
    var profileImageURL : String
    
    init(email: String, uid: String, username: String, groups: Dictionary<String,String>, profileImageURL: String) {
        self.email = email
        self.uid = uid
        self.username = username
        self.groups = groups
        self.profileImageURL = profileImageURL
    }
    
    convenience override init() {
        self.init(email: "what", uid: "aye", username: "Error", groups: Dictionary<String,String>(), profileImageURL: "")
    }
}
