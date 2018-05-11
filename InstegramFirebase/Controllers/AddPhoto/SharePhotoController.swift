//
//  SharePhotoController.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 4/03/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit
import Firebase

class SharePhotoController: UIViewController {
    var image: UIImage? {
        didSet {
            if let img = image {
                photoImageView.image = img
            }
        }
    }
    
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let descTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        tv.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        setupViews()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func setupViews(){
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        view.addSubview(containerView)
        containerView.anchor(topAnchor: view.safeAreaLayoutGuide.topAnchor, paddingTop: 0, bottomAnchor: nil, paddingBottom: 0, leftAnchor: view.leftAnchor, paddingLeft: 0, rightAnchor: view.rightAnchor, paddingRight: 0, widthConstant: 0, heightConstant: 100, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
        
        containerView.addSubview(photoImageView)
        photoImageView.anchor(topAnchor: containerView.topAnchor, paddingTop: 8, bottomAnchor: containerView.bottomAnchor, paddingBottom: -8, leftAnchor: containerView.leftAnchor, paddingLeft: 8, rightAnchor: nil, paddingRight: 0, widthConstant:  100 - 8 - 8, heightConstant: 0, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
        
        containerView.addSubview(descTextView)
        descTextView.anchor(topAnchor: containerView.topAnchor, paddingTop: 0, bottomAnchor: containerView.bottomAnchor, paddingBottom: 0, leftAnchor: photoImageView.rightAnchor, paddingLeft: 0, rightAnchor: containerView.rightAnchor, paddingRight: 0, widthConstant: 0, heightConstant: 0, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
        
    }
    
    //handlers
    @objc private func handleShare(){
        print("handleShare")
        let filename = NSUUID().uuidString
        guard let selectedImage = self.image, let data = UIImageJPEGRepresentation(selectedImage, 0.1) else { return }
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let fileRef = Storage.storage().reference().child(DBChild.posts.rawValue).child(filename)
        
        fileRef.putData(data, metadata: nil) { (metadata, error) in
            if let err = error {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print(err)
                return
            }
            
            fileRef.downloadURL(completion: { (url, error) in
                if let err = error {
                    log.error("failed to get image url", context: err)
                }
                
                guard let imageUrl = url?.absoluteString else { return }
                NotificationCenter.default.post(name: HomeController.refreshNotificationName, object: nil)
                self.saveToDatabaseWithImageUrl(url: imageUrl)
            })
        }
    }
    
    private func saveToDatabaseWithImageUrl(url: String){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let postImage = self.image else { return }
        
        let postRef = Database.database().reference().child(DBChild.posts.rawValue).child(uid).childByAutoId()
        
        var values = [
            "imageUrl": url,
            "imageWidth": postImage.size.width,
            "imageHeight": postImage.size.height,
            "creationDate": Date().timeIntervalSince1970
        ] as [String: Any]
        
        guard let text = self.descTextView.text else { return }
        
        if text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != "" {
            values["text"] = text
        }

        postRef.updateChildValues(values) { (error, ref) in
            if let err = error {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print(err)
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}
