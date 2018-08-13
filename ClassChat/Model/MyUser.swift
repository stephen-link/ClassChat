//
//  MyUser.swift
//  ClassChat
//
//  Created by Stephen Link on 8/5/18.
//  Copyright © 2018 Stephen Link. All rights reserved.
//

import Foundation

struct MyUser {
    var email: String
    var password: String
    var uid: String
    
    init(email: String, password: String, uid: String) {
        self.email = email
        self.password = password
        self.uid = uid
    }
}
