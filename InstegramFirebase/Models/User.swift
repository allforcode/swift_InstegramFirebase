//
//  User.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 11/02/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import Foundation

struct User {
    var uid: String?
    var username: String?
    var profileImageUrl: String?
    
    init(uid: String?, dictionary: [String: Any]) {
        if let uid = uid {
            self.uid = uid
        }

        if let username = dictionary["username"] as? String {
            self.username = username
        }
        
        if let profileImageUrl = dictionary["profileImageUrl"] as? String {
            self.profileImageUrl = profileImageUrl
        }
    }
}
