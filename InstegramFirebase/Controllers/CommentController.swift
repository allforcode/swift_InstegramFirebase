//
//  CommentController.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 30/04/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit
import Firebase

class CustomView: UIView {
    // this is needed so that the inputAccesoryView is properly sized from the auto layout constraints
    // actual value is not important
    override var intrinsicContentSize: CGSize {
//        return CGSize.zero
        return CGSize(width: 1000, height: 50)
    }
}


class CommentController: UICollectionViewController {
    var post: Post?
    
    let commentTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter Comment..."
        return tf
    }()
    
    lazy var containerView: CustomView = {
        let v = CustomView()
        v.backgroundColor = .white
        v.autoresizingMask = .flexibleHeight
        
        let b = UIButton()
        
        b.setTitle("Submit", for: .normal)
        b.setTitleColor(.black, for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        b.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        
        v.addSubview(b)
        b.anchor(topAnchor: v.safeAreaLayoutGuide.topAnchor, paddingTop: 0, bottomAnchor: v.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 0, leftAnchor: nil, paddingLeft: 0, rightAnchor: v.rightAnchor, paddingRight: -12, widthConstant: 50, heightConstant: 0, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)

        v.addSubview(self.commentTextField)
//        self.commentTextField.adjustsFontSizeToFitWidth = false
        self.commentTextField.anchor(topAnchor: v.safeAreaLayoutGuide.topAnchor, paddingTop: 0, bottomAnchor: v.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 0, leftAnchor: v.leftAnchor, paddingLeft: 12, rightAnchor: b.leftAnchor, paddingRight: -8, widthConstant: 0, heightConstant: 0, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
        
        return v
    }()
    
    @objc private func handleSubmit(){
        log.verbose("handle submit")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let text = commentTextField.text else { return }
        
        let value = [
            "text": text,
            "creationDate": Date().timeIntervalSince1970,
            "uid": uid
        ] as [String: Any]
        
        Database.database().reference().child(DBChild.comments.rawValue).childByAutoId().updateChildValues(value) { (error, ref) in
            
            if let err = error {
                log.error("Failed to save comment", context: err)
            }
        }
    }
    
    override func viewDidLoad() {
        self.collectionView?.backgroundColor = .yellow
        navigationItem.title = "Comments"
    }
    
    override var inputAccessoryView: UIView? {
        return containerView
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}
