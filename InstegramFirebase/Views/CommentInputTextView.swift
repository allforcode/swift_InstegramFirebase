//
//  CommentInputTextView.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 3/06/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit

class CommentInputTextView: UITextView {
    private let placeholderLabel: UILabel = {
        let l = UILabel()
        l.text = "Enter Comment..."
        l.textColor = UIColor.lightGray
        return l
    }()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(topAnchor: topAnchor, paddingTop: 0, bottomAnchor: bottomAnchor, paddingBottom: 0, leftAnchor: leftAnchor, paddingLeft: 4, rightAnchor: rightAnchor, paddingRight: 0, widthConstant: 0, heightConstant: 0, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: centerYAnchor, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
    }
    
    @objc private func handleTextChange() {
        self.placeholderLabel.isHidden = !self.text.isEmpty
    }
    
    func showPlaceholderLabel(to isHidden: Bool) {
        self.placeholderLabel.isHidden = !isHidden
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
