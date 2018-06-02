//
//  CustomInputContainerView.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 13/05/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit

class CommentInputAccessoryView: UIView {

    var delegate: CommentInputAccessoryViewDelegate?
    
    private lazy var submitButton: UIButton = {
        let b = UIButton()
        b.setTitle("Submit", for: .normal)
        b.setTitleColor(.black, for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        b.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return b
    }()
    
    private let commentTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter Comment..."
        return tf
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        autoresizingMask = .flexibleHeight
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(){
        addSubview(submitButton)
        submitButton.anchor(topAnchor: safeAreaLayoutGuide.topAnchor, paddingTop: 0, bottomAnchor: safeAreaLayoutGuide.bottomAnchor, paddingBottom: 0, leftAnchor: nil, paddingLeft: 0, rightAnchor: rightAnchor, paddingRight: -12, widthConstant: 50, heightConstant: 0, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
        
        addSubview(self.commentTextField)
        commentTextField.anchor(topAnchor: safeAreaLayoutGuide.topAnchor, paddingTop: 0, bottomAnchor: safeAreaLayoutGuide.bottomAnchor, paddingBottom: 0, leftAnchor: leftAnchor, paddingLeft: 12, rightAnchor: submitButton.leftAnchor, paddingRight: -8, widthConstant: 0, heightConstant: 0, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
        
        setupLinSeparatorView()
    }
    
    private func setupLinSeparatorView(){
        let seperatorLineView = UIView()
        seperatorLineView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        
        addSubview(seperatorLineView)
        seperatorLineView.anchor(topAnchor: topAnchor, paddingTop: 0, bottomAnchor: nil, paddingBottom: 0, leftAnchor: leftAnchor, paddingLeft: 0, rightAnchor: rightAnchor, paddingRight: 0, widthConstant: 0, heightConstant: 0.5, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
    }
    
//    // this is needed so that the inputAccesoryView is properly sized from the auto layout constraints
//    // actual value is not important
//    override var intrinsicContentSize: CGSize {
//        //        return CGSize.zero
//        return CGSize(width: 1000, height: 50)
//    }
    
    @objc private func handleSubmit(){
        log.verbose("handle submit")
        guard let commentText = self.commentTextField.text else { return }
        delegate?.didSubmit(for: commentText)
    }
    
    func clearCommentText(){
         self.commentTextField.text = nil
    }
}
