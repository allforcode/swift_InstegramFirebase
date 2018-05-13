//
//  CustomInputContainerView.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 13/05/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit

class CustomInputContainerView: UIView {
    // this is needed so that the inputAccesoryView is properly sized from the auto layout constraints
    // actual value is not important
    override var intrinsicContentSize: CGSize {
        //        return CGSize.zero
        return CGSize(width: 1000, height: 50)
    }
}
