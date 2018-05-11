//
//  Helper.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 3/02/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit

class Helper {
    static func createTextField(placeholder: String, secured: Bool, selector: Selector, target: Any?) -> UITextField {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.placeholder = placeholder
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.isSecureTextEntry = secured
        tf.addTarget(target, action: selector, for: .editingChanged)
        return tf
    }
}

