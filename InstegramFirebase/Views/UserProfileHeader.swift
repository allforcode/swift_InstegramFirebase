//
//  UserProfileHeader.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 11/02/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit
import Firebase

class UserProfileHeader: UICollectionViewCell {
    
    var delegate: UserProfileViewDelegate?
    
    var user: User? {
        didSet {
            if let user = self.user {
                usernameLabel.text = user.username
                postsLabel.setStatsNumber(numberString: "32")
                followersLabel.setStatsNumber(numberString: "43")
                followingLabel.setStatsNumber(numberString: "233")
                self.setupProfileImage()
                self.checkUserRelation(user)
            }
        }
    }
    
    private func checkUserRelation(_ user: User){
        if user.uid == Auth.auth().currentUser?.uid {
            print("it's current user")
            self.setStyle(when: .isSelf)
        } else {
            print("it's selected user")
            //check the user is followed
            guard let currentLoginUserId = Auth.auth().currentUser?.uid, let followedUserId = self.user?.uid else { return }
            
            let ref  = Database.database().reference().child(DBChild.followers.rawValue).child(currentLoginUserId).child(followedUserId)
            
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if let value = snapshot.value as? Bool, value == true {
                    self.setStyle(when: .followed)
                }else{
                    self.setStyle(when: .unfollowed)
                }
            }
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .clear
        iv.layer.cornerRadius = 40
        iv.layer.masksToBounds = true //or iv.clipsToBounds = true
        return iv
    }()
    
    lazy var gridButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        b.tag = ButtonTag.grid.rawValue
        b.addTarget(self, action: #selector(handleViewChange), for: .touchUpInside)
        return b
    }()
    
    lazy var listButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        b.tintColor = UIColor(white: 0, alpha: 0.2)
        b.tag = ButtonTag.list.rawValue
        b.addTarget(self, action: #selector(handleViewChange), for: .touchUpInside)
        return b
    }()
    
    let bookmarkButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        b.tintColor = UIColor(white: 0, alpha: 0.2)
        return b
    }()
    
    let usernameLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = UIFont.boldSystemFont(ofSize: 16)
        return l
    }()
    
    let postsLabel: StatLabel = {
        return StatLabel(descString: "posts")
    }()
    
    let followersLabel: StatLabel = {
        return StatLabel(descString: "followers")
    }()
    
    let followingLabel: StatLabel = {
        return StatLabel(descString: "following")
    }()
    
    lazy var editProfileAndFollowButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Edit Profile", for: .normal)
        b.setTitleColor(.black, for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        b.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        b.layer.borderWidth = 1
        b.layer.cornerRadius = 4
        b.addTarget(self, action: #selector(handleEditProfileAndFollowButton), for: .touchUpInside)
        return b
    }()
    
    @objc func handleEditProfileAndFollowButton(){
        guard let currentTitle = self.editProfileAndFollowButton.currentTitle else { return }
        print("handleEditProfileAndFollowButton", currentTitle)
        
        switch currentTitle {
        case "Follow":
            print("do following")
            self.handleFollow(toFollow: true)
        case "Unfollow":
            print("do unfollowing")
            self.handleFollow(toFollow: false)
        default:
            print("do editing")
        }
    }
    
    @objc func handleViewChange(_ sender: Any){
        log.verbose("sender: ", context: sender)
        guard let viewButton = sender as? UIButton else { return }
        viewButton.tintColor = UIColor.darkerBlue
        
        if viewButton.tag == ButtonTag.grid.rawValue {
            listButton.tintColor = UIColor.darkGray
        }else if viewButton.tag == ButtonTag.list.rawValue {
            gridButton.tintColor = UIColor.darkGray
        }
        
        delegate?.didChangeView(viewButton.tag)
    }
    
    func handleFollow(toFollow: Bool) {
        guard let currentLoginUserId = Auth.auth().currentUser?.uid, let followUserId = self.user?.uid else { return }
        let values = [followUserId: toFollow]
        Database.database().reference().child(DBChild.followers.rawValue).child(currentLoginUserId).updateChildValues(values) { (error, ref) in
            if let err = error {
                print("Failed to follow this user", err)
                return
            }

            if toFollow {
                self.setStyle(when: .followed)
            }else {
                self.setStyle(when: .unfollowed)
            }
            
            NotificationCenter.default.post(name: HomeController.refreshNotificationName, object: nil)
        }
    }
    
    func setStyle(when: FollowRelation) {
        switch when {
        case .followed:
            self.editProfileAndFollowButton.setTitle("Unfollow", for: .normal)
            self.editProfileAndFollowButton.setTitleColor(.black, for: .normal)
            self.editProfileAndFollowButton.backgroundColor = UIColor.white
        case .unfollowed:
            self.editProfileAndFollowButton.setTitle("Follow", for: .normal)
            self.editProfileAndFollowButton.setTitleColor(.white, for: .normal)
            self.editProfileAndFollowButton.backgroundColor = UIColor.darkerBlue
        default:
            //for login user
            editProfileAndFollowButton.setTitle("Edit Profile", for: .normal)
            editProfileAndFollowButton.setTitleColor(.black, for: .normal)
            editProfileAndFollowButton.backgroundColor = UIColor.white
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.anchor(topAnchor: topAnchor, paddingTop: 12, bottomAnchor: nil, paddingBottom: 0, leftAnchor: leftAnchor, paddingLeft: 12, rightAnchor: nil, paddingRight: 0, widthConstant: 80, heightConstant: 80, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
        
        addSubview(usernameLabel)
        usernameLabel.anchor(topAnchor: profileImageView.bottomAnchor, paddingTop: 8, bottomAnchor: nil, paddingBottom: 0, leftAnchor: leftAnchor, paddingLeft: 12, rightAnchor: nil, paddingRight: 0, widthConstant: 80, heightConstant: 20, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
        
        setupBottomToolbar()
        setupUserStatsViews()
    }
    
    private func setupProfileImage(){
        guard let urlString = self.user?.profileImageUrl else { return }
        self.profileImageView.loadImage(urlString: urlString)
    }
    
    private func setupBottomToolbar(){
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor.lightGray
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor.lightGray
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        
        stackView.addSubview(topDividerView)
        topDividerView.anchor(topAnchor: stackView.topAnchor, paddingTop: 0, bottomAnchor: nil, paddingBottom: 0, leftAnchor: stackView.leftAnchor, paddingLeft: 0, rightAnchor: stackView.rightAnchor, paddingRight: 0, widthConstant: 0, heightConstant: 1, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
        
        stackView.addSubview(bottomDividerView)
        bottomDividerView.anchor(topAnchor: nil, paddingTop: 0, bottomAnchor: stackView.bottomAnchor, paddingBottom: 0, leftAnchor: stackView.leftAnchor, paddingLeft: 0, rightAnchor: stackView.rightAnchor, paddingRight: 0, widthConstant: 0, heightConstant: 1, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
        
        addSubview(stackView)
        stackView.anchor(topAnchor: nil, paddingTop: 0, bottomAnchor: bottomAnchor, paddingBottom: 0, leftAnchor: leftAnchor, paddingLeft: 0, rightAnchor: rightAnchor, paddingRight: 0, widthConstant: 0, heightConstant: 50, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
    }
    
    private func setupUserStatsViews(){
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        
        addSubview(stackView)
        stackView.anchor(topAnchor: profileImageView.topAnchor, paddingTop: 0, bottomAnchor: nil, paddingBottom: 0, leftAnchor: profileImageView.rightAnchor, paddingLeft: 12, rightAnchor: rightAnchor, paddingRight: -12, widthConstant: 0, heightConstant: 50, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)

        addSubview(editProfileAndFollowButton)
        editProfileAndFollowButton.anchor(topAnchor: stackView.bottomAnchor, paddingTop: 0, bottomAnchor: nil, paddingBottom: 0, leftAnchor: stackView.leftAnchor, paddingLeft: 0, rightAnchor: stackView.rightAnchor, paddingRight: 0, widthConstant: 0, heightConstant: 34, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)

        print("\(user?.username ?? "") in UserProfileHeader")

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
