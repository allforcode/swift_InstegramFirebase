//
//  ViewController+delegates.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 4/02/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit

extension SignUpController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(info)
        
        let finalImage: UIImage
        var success = false
        
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            success = true
            finalImage = originalImage
        } else if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            success = true
            finalImage = editedImage
        } else {
            finalImage = #imageLiteral(resourceName: "plus_photo")
        }
        
        if success, let data = UIImageJPEGRepresentation(finalImage, 0.3) {
            self.plusPhotoButton.setImage(UIImage(data: data), for: .normal)
        } else {
            self.plusPhotoButton.setImage(finalImage, for: .normal)
        }
        
        if success {
            self.plusPhotoButton.layer.cornerRadius = self.plusPhotoButton.frame.width / 2
            self.plusPhotoButton.layer.masksToBounds = true
            self.plusPhotoButton.layer.borderColor = UIColor.black.cgColor
            self.plusPhotoButton.layer.borderWidth = 2
        }
        
        dismiss(animated: true, completion: nil)
    }
}
