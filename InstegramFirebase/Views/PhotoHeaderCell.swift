//
//  PhotoHeaderCell.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 4/03/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit

class PhotoHeaderCell: UICollectionViewCell {
    var image: UIImage? {
        didSet {
            if let img = image {
                self.photoImageView.image = img
            }
        }
    }
    
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.cyan
        
        addSubview(photoImageView)
        photoImageView.anchor(topAnchor: topAnchor, paddingTop: 0, bottomAnchor: bottomAnchor, paddingBottom: 0, leftAnchor: leftAnchor, paddingLeft: 0, rightAnchor: rightAnchor, paddingRight: 0, widthConstant: 0, heightConstant: 0, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
