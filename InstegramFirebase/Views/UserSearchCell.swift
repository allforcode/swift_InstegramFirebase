//
//  UserSearchCell.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 7/04/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit

class UserSearchCell: UICollectionViewCell {
    var user: User? {
        didSet {
            guard let user = self.user, let userProfileImageUrl = user.profileImageUrl else { return }
            self.profileImageView.loadImage(urlString: userProfileImageUrl)
            self.usernameLabel.text = user.username
        }
    }
    
    let profileImageView: CustomImageView = {
        let civ = CustomImageView()
        civ.layer.cornerRadius = 22
        civ.contentMode = .scaleAspectFill
        civ.clipsToBounds = true
        return civ
    }()
    
    let usernameLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.boldSystemFont(ofSize: 14)
        return l
    }()
    
    let separatorView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.rgb(230)
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(profileImageView)
        addSubview(usernameLabel)
        addSubview(separatorView)

        profileImageView.anchor(topAnchor: nil, paddingTop: 0, bottomAnchor: nil, paddingBottom: 0, leftAnchor: leftAnchor, paddingLeft: 8, rightAnchor: nil, paddingRight: 0, widthConstant: 44, heightConstant: 44, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: centerYAnchor, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
        
        usernameLabel.anchor(topAnchor: nil, paddingTop: 0, bottomAnchor: nil, paddingBottom: 0, leftAnchor: profileImageView.rightAnchor, paddingLeft: 8, rightAnchor: rightAnchor, paddingRight: -8, widthConstant: 0, heightConstant: 0, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: centerYAnchor, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
        
        separatorView.anchor(topAnchor: nil, paddingTop: 0, bottomAnchor: bottomAnchor, paddingBottom: 0, leftAnchor: profileImageView.rightAnchor, paddingLeft: 8, rightAnchor: rightAnchor, paddingRight: 0, widthConstant: 0, heightConstant: 0.5, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
