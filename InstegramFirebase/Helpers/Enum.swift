//
//  Enum.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 4/02/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import Foundation

enum DBChild: String {
    case users
    case profileImages = "profile_images"
    case posts
    case username
    case profileImageUrl
    case followers
    case comments
    case likes
}

enum FollowRelation{
    case followed
    case unfollowed
    case isSelf
}

enum ButtonTag: Int {
    case grid
    case list
}
