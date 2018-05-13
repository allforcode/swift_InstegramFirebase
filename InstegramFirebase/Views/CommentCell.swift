//
//  CommentCell.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 13/05/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit
import Firebase

class CommentCell: UICollectionViewCell {
    
    var comment: Comment? {
        didSet {
            guard
                let user = self.comment?.user,
                let userProfileImageUrl = user.profileImageUrl,
                let username = user.username,
                let commentText = comment?.text
                else {
                    return
                }
            self.userProfileImageView.loadImage(urlString: userProfileImageUrl)
            
            let attributedString = NSMutableAttributedString(string: "\(username): ", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14)])
            attributedString.append(NSAttributedString(string: commentText, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14)]))
            
            textLabel.attributedText = attributedString
        }
    }
    
    let userProfileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .blue
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let textLabel: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.isScrollEnabled = false
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(userProfileImageView)
        addSubview(textLabel)
        
        let userProfileImageWidth: CGFloat = 40
        userProfileImageView.layer.cornerRadius = userProfileImageWidth / 2
        
        userProfileImageView.anchor(topAnchor: topAnchor, paddingTop: 8, bottomAnchor: nil, paddingBottom: 0, leftAnchor: leftAnchor, paddingLeft: 8, rightAnchor: nil, paddingRight: 0, widthConstant: userProfileImageWidth, heightConstant: userProfileImageWidth, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)

        textLabel.anchor(topAnchor: topAnchor, paddingTop: 8, bottomAnchor: bottomAnchor, paddingBottom: -8, leftAnchor: userProfileImageView.rightAnchor, paddingLeft: 8, rightAnchor: rightAnchor, paddingRight: -8, widthConstant: 0, heightConstant: 0, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
