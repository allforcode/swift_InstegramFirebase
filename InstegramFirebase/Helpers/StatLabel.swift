//
//  StatLabel.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 11/02/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit

class StatLabel: UILabel {
    var descString: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(descString: String){
        self.init(frame: CGRect.zero)
        self.descString = descString
    }
    
    func setStatsNumber(numberString: String) {
        self.textAlignment = .center
        self.numberOfLines = 0
        let numberTextAttributes = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.black]
        
        let attributedText = NSMutableAttributedString(string: numberString, attributes: numberTextAttributes)
        
        attributedText.append(NSAttributedString(string: "\n"))
        
        let descTextAttributes = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.lightGray]
        
        if let descString = self.descString {
            attributedText.append(NSAttributedString(string: descString.uppercased(), attributes: descTextAttributes))
        }
        
        self.attributedText = attributedText
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
