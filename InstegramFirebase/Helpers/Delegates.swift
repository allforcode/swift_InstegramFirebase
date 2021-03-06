//
//  Delegates.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 30/04/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import Foundation

protocol HomePostCellDelegate {
    func didTapComment(post: Post)
    func didTapLike(cell: HomePostCell)
}

protocol UserProfileViewDelegate {
    func didChangeView(_ changeTo: Int)
}

protocol CommentInputAccessoryViewDelegate {
    func didSubmit(for comment: String)
}
