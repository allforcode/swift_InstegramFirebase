//
//  PreviewPhotoContainerView.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 22/04/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit
import Photos

class PreviewPhotoContainerView: UIView {
    let previewImageView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    let cancelButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(#imageLiteral(resourceName: "cancel_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        b.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        b.backgroundColor = UIColor(white: 0, alpha: 0.3)
        b.layer.cornerRadius = 5
        b.clipsToBounds = true
        b.layer.borderWidth = 0.5
        b.layer.borderColor = UIColor.white.cgColor
        return b
    }()
    
    let saveButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(#imageLiteral(resourceName: "save_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        b.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        b.backgroundColor = UIColor(white: 0, alpha: 0.3)
        b.layer.cornerRadius = 5
        b.layer.borderWidth = 0.5
        b.clipsToBounds = true
        b.layer.borderColor = UIColor.white.cgColor
        return b
    }()
    
    let saveLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.textAlignment = .center
        l.backgroundColor = UIColor(white: 0, alpha: 0.3)
        l.textColor = .white
        l.layer.cornerRadius = 6
        l.clipsToBounds = true
        l.layer.borderWidth = 0.5
        l.layer.borderColor = UIColor.white.cgColor
        l.isHidden = true
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(previewImageView)
        addSubview(cancelButton)
        addSubview(saveButton)
        previewImageView.addSubview(saveLabel)
        
        previewImageView.anchor(topAnchor: topAnchor, bottomAnchor: bottomAnchor, leftAnchor: leftAnchor, rightAnchor: rightAnchor)
        cancelButton.anchor(topAnchor: topAnchor, paddingTop: 24, bottomAnchor: nil, paddingBottom: 0, leftAnchor: leftAnchor, paddingLeft: 24, rightAnchor: nil, paddingRight: 0, widthConstant: 40, heightConstant: 40, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
        saveButton.anchor(topAnchor: nil, paddingTop: 0, bottomAnchor: bottomAnchor, paddingBottom: -24, leftAnchor: leftAnchor, paddingLeft: 24, rightAnchor: nil, paddingRight: 0, widthConstant: 40, heightConstant: 40, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
        
        saveLabel.anchor(topAnchor: nil, paddingTop: 0, bottomAnchor: nil, paddingBottom: 0, leftAnchor: nil, paddingLeft: 0, rightAnchor: nil, paddingRight: 0, widthConstant: 150, heightConstant: 80, centerXAnchor: centerXAnchor, paddingCenterX: 0, centerYAnchor: centerYAnchor, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)

        
    }
    
    @objc func handleCancel() {
        self.removeFromSuperview()
    }
    
    @objc func handleSave() {
        guard let previewImage = self.previewImageView.image else { return }
        let photoLibrary = PHPhotoLibrary.shared()
        photoLibrary.performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
            self.showSavelabel("Saving ...")
        }) { (success, err) in
            if let e = err {
                log.error("Failed to save image", context: e)
                return
            }
            
            if success {
                self.setLabelText("Image saved\nsuccessfully", completion: {
                    self.hideSaveLabel()
                })
            }
        }
    }
    
    private func showSavelabel(_ text: String){
        log.verbose("show save label")
        DispatchQueue.main.async {
            self.saveLabel.text = text
            self.saveLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
            self.saveLabel.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.saveLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                self.saveLabel.alpha = 1
                self.saveLabel.isHidden = false
            }, completion: nil)
        }
    }
    
    private func setLabelText(_ text: String, completion: (() -> Void)?){
        log.verbose("set label text")
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.saveLabel.text = text
            }, completion: { (_) in
                log.verbose("complete to set label text")
                if let callback = completion {
                    callback()
                }
            })
        }
    }
    
    private func hideSaveLabel(){
        log.verbose("hide save label")
        DispatchQueue.main.async {
            self.saveLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
            self.saveLabel.alpha = 1
            UIView.animate(withDuration: 0.5, delay: 2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                log.verbose("start to hide")
                self.saveLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                self.saveLabel.alpha = 0
            }, completion: { ( _ ) in
                log.verbose("finished to hide save label")
                self.saveLabel.isHidden = true
                self.removeFromSuperview()
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
