//
//  HomePostCell.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 1/04/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit

class HomePostCell: UICollectionViewCell {
    
    var delegate: HomePostCellDelegate?
    
    var post: Post? {
        didSet {
            guard let post = self.post else { return }
            
            if let imageUrl = post.imageUrl {
                self.photoImageView.loadImage(urlString: imageUrl)
            }
            
            setAttributedCaption()

            guard let user = post.user else { return }
            
            if let userProfileImageUrl = user.profileImageUrl {
                self.userProfileImageView.loadImage(urlString: userProfileImageUrl)
            }
            
            if let username = user.username {
                self.usernameLabel.text = username
            }
            
        }
    }
    
    let userProfileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 20
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let l = UILabel()
        l.text = "username"
        l.font = UIFont.boldSystemFont(ofSize: 14)
        return l
    }()
    
    let optionsButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("•••", for: .normal)
        b.setTitleColor(.black, for: .normal)
        return b
    }()
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let likeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(#imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
        return b
    }()
    
    lazy var commentButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(#imageLiteral(resourceName: "comment").withRenderingMode(.alwaysOriginal), for: .normal)
        b.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return b
    }()
    
    let sendMessageButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(#imageLiteral(resourceName: "send2").withRenderingMode(.alwaysOriginal), for: .normal)
        return b
    }()
    
    let bookMarkButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(#imageLiteral(resourceName: "ribbon").withRenderingMode(.alwaysOriginal), for: .normal)
        return b
    }()
    
    let captionLabel: UILabel = {
        let l = UILabel()
        
        l.numberOfLines = 0
        return l
    }()
    
    private func setAttributedCaption() {
        guard let post = self.post, let user = post.user else { return }
        
        if let username = user.username {
            let attributedString = NSMutableAttributedString(string: username, attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14)])
            attributedString.append(NSAttributedString(string: " "))
            
            if let caption = post.text {
                attributedString.append(NSMutableAttributedString(string: caption, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14)]))
            }else {
                attributedString.append(NSMutableAttributedString(string: "NO CAPTION", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14)]))
            }
            
            attributedString.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 4)]))
            
            if let creationgDate = post.creationDate {
                let timeAgoDisplay = creationgDate.timeAgoDisplay()
                attributedString.append(NSMutableAttributedString(string: timeAgoDisplay, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12), NSAttributedStringKey.foregroundColor : UIColor.lightGray]))
            }
            
            self.captionLabel.attributedText = attributedString
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(userProfileImageView)
        addSubview(optionsButton)
        addSubview(usernameLabel)
        addSubview(photoImageView)
        addSubview(captionLabel)
        
        userProfileImageView.anchor(topAnchor: topAnchor, paddingTop: 8, bottomAnchor: nil, paddingBottom: 0, leftAnchor: leftAnchor, paddingLeft: 8, rightAnchor: nil, paddingRight: 0, widthConstant: 40, heightConstant: 40, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)

        optionsButton.anchor(topAnchor: userProfileImageView.topAnchor, paddingTop: 0, bottomAnchor: userProfileImageView.bottomAnchor, paddingBottom: 0, leftAnchor: nil, paddingLeft: 0, rightAnchor: rightAnchor, paddingRight: -8, widthConstant: 50, heightConstant: 0, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)

        usernameLabel.anchor(topAnchor: userProfileImageView.topAnchor, paddingTop: 0, bottomAnchor: userProfileImageView.bottomAnchor, paddingBottom: 0, leftAnchor: userProfileImageView.rightAnchor, paddingLeft: 8, rightAnchor: optionsButton.leftAnchor, paddingRight: -8, widthConstant: 0, heightConstant: 0, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)

        photoImageView.anchor(topAnchor: userProfileImageView.bottomAnchor, paddingTop: 8, bottomAnchor: nil, paddingBottom: 0, leftAnchor: leftAnchor, paddingLeft: 0, rightAnchor: rightAnchor, paddingRight: 0, widthConstant: 0, heightConstant: 0, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: widthAnchor, heightMultiplier: 0.75)

        setupActionButtons()

        captionLabel.anchor(topAnchor: bookMarkButton.bottomAnchor, paddingTop: 8, bottomAnchor: bottomAnchor, paddingBottom: 0, leftAnchor: leftAnchor, paddingLeft: 8, rightAnchor: rightAnchor, paddingRight: -8, widthConstant: 0, heightConstant: 0, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
    }
    
    private func setupActionButtons(){
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, sendMessageButton])
        stackView.backgroundColor = .green
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        
        addSubview(stackView)
        stackView.anchor(topAnchor: photoImageView.bottomAnchor, paddingTop: 8, bottomAnchor: nil, paddingBottom: 0, leftAnchor: leftAnchor, paddingLeft: 8, rightAnchor: nil, paddingRight: 0, widthConstant: 120, heightConstant: 50, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
        
        addSubview(bookMarkButton)
        bookMarkButton.anchor(topAnchor: photoImageView.bottomAnchor, paddingTop: 8, bottomAnchor: nil, paddingBottom: 0, leftAnchor: nil, paddingLeft: 0, rightAnchor: rightAnchor, paddingRight: -8, widthConstant: 40, heightConstant: 50, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
    }
    
    @objc func handleComment(){
        log.verbose("handleComment")
        guard let post = self.post else { return }
        delegate?.didTapComment(post: post)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
