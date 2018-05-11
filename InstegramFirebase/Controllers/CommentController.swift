//
//  CommentController.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 30/04/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit

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
    
    lazy var containerView: CustomView = {
        let v = CustomView()
        v.backgroundColor = .white
        v.autoresizingMask = .flexibleHeight
        
        let tf = UITextField()
        let b = UIButton()
        tf.placeholder = "Enter Comment..."
        
        b.setTitle("Submit", for: .normal)
        b.setTitleColor(.black, for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        b.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        
        v.addSubview(b)
        b.anchor(topAnchor: v.safeAreaLayoutGuide.topAnchor, paddingTop: 0, bottomAnchor: v.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 0, leftAnchor: nil, paddingLeft: 0, rightAnchor: v.rightAnchor, paddingRight: -12, widthConstant: 50, heightConstant: 0, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)

        v.addSubview(tf)
        tf.adjustsFontSizeToFitWidth = false
        tf.anchor(topAnchor: v.safeAreaLayoutGuide.topAnchor, paddingTop: 0, bottomAnchor: v.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 0, leftAnchor: v.leftAnchor, paddingLeft: 12, rightAnchor: b.leftAnchor, paddingRight: -8, widthConstant: 0, heightConstant: 0, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)

        
        return v
    }()
    
    @objc private func handleSubmit(){
        log.verbose("handle submit")
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
