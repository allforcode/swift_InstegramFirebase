//
//  Post.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 30/03/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit

struct Post {
    var imageUrl: String?
    var text: String?
    var imageHeight: CGFloat?
    var imageWidth: CGFloat?
    var creationDate: Date?
    var user: User?
    
    init(dictionary: [String: Any]) {
        self.imageUrl =  dictionary["imageUrl"] as? String
        self.text = dictionary["text"] as? String
        self.imageHeight = dictionary["imageHeight"] as? CGFloat
        self.imageWidth = dictionary["imageWidth"] as? CGFloat
        guard let timeInterval = dictionary["creationDate"] as? TimeInterval else { return }
        self.creationDate = Date(timeIntervalSince1970: timeInterval)
        self.user = dictionary["user"] as? User
    }
}
