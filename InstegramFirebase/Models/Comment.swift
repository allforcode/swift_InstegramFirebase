//
//  Comment.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 13/05/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit

class Comment {
    var id: String?
    var text: String?
    var creationDate: Date?
    var user: User?
    
    init(_ dic: [String: Any]) {
        self.text = dic["text"] as? String
        guard let timeInterval = dic["creationDate"] as? TimeInterval else { return }
        self.creationDate = Date(timeIntervalSince1970: timeInterval)
    }
}
