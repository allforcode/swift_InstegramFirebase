//
//  ViewController.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 3/02/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit
import Firebase

class SignUpController: UIViewController {
    //MARK: properties
    lazy var plusPhotoButton: UIButton = {
        let b = UIButton()
        b.setBackgroundImage(#imageLiteral(resourceName: "plus_photo"), for: .normal)
//        b.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        return b
    }()

    lazy var emailTextField: UITextField = {
        return Helper.createTextField(placeholder: "Email", secured: false, selector: #selector(self.handleTextInputChange), target: self)
    }()
    
    lazy var usernameTextField: UITextField = {
        return Helper.createTextField(placeholder: "Username", secured: false, selector: #selector(self.handleTextInputChange), target: self)
    }()
    
    lazy var passwordTextField: UITextField = {
        return Helper.createTextField(placeholder: "Password", secured: true, selector: #selector(self.handleTextInputChange), target: self)
    }()
    
    let alreadyHaveAccountButton: UIButton = {
        let b = UIButton(type: .system)
        //attributed title
        let attributedString = NSMutableAttributedString(string: "Already have an account? ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray])
        attributedString.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedStringKey.foregroundColor : UIColor.darkerBlue, .font: UIFont.boldSystemFont(ofSize: 14)]))
        b.setAttributedTitle(attributedString, for: UIControlState.normal)
        
        b.addTarget(self, action: #selector(handleAlreadyHaveAccount), for: .touchUpInside)
        return b
    }()
    
    lazy var signUpButton: UIButton = {
        let b = UIButton(type: .system)
        b.isEnabled = false
        b.setTitle("Sign Up", for: .normal)
        b.backgroundColor = UIColor.lighterBlue
        b.layer.cornerRadius = 5
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        b.setTitleColor(.white, for: .normal)
        b.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return b
    }()

    //MARK: overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupPlusButton()
        setupStackView()
        setupAlreadyHaveAccountButton()
    }

    //MARK: setup
    private func setupPlusButton() {
        self.view.addSubview(plusPhotoButton)
        plusPhotoButton.anchor(topAnchor: view.topAnchor, paddingTop: 40, bottomAnchor: nil, paddingBottom: 0, leftAnchor: nil, paddingLeft: 0, rightAnchor: nil, paddingRight: 0, widthConstant: 140, heightConstant: 140, centerXAnchor: view.centerXAnchor, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
    }
    
    private func setupStackView() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, signUpButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        
        view.addSubview(stackView)
        stackView.anchor(topAnchor: plusPhotoButton.bottomAnchor, paddingTop: 20, bottomAnchor: nil, paddingBottom: 0, leftAnchor: view.leftAnchor, paddingLeft: 40, rightAnchor: view.rightAnchor, paddingRight: -40, widthConstant: 0, heightConstant: 200, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
    }
    
    private func setupAlreadyHaveAccountButton(){
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(topAnchor: nil, paddingTop: 0, bottomAnchor: view.bottomAnchor, paddingBottom: 0, leftAnchor: view.leftAnchor, paddingLeft: 0, rightAnchor: view.rightAnchor, paddingRight: 0, widthConstant: 0, heightConstant: 50, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
    }
}

extension SignUpController {
    //MARK: handlers
    @objc private func handlePlusPhoto(){
        print("handle plus photo")
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc private func handleSignUp(){
        print("handle Sign Up")
        guard let email = emailTextField.text, email.count > 0, let username = usernameTextField.text, username.count > 0, let password = passwordTextField.text, password.count > 0 else { return }

        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let err = error {
                print(err)
                return
            }
            
            guard let uid = user?.user.uid else { return }
            
            //upload profile image
            guard let image = self.plusPhotoButton.imageView?.image, let imageData = UIImageJPEGRepresentation(image, 1) else { return }
            
            let imageName = NSUUID().uuidString + ".jpg"
            
            let imageRef = Storage.storage().reference().child(DBChild.profileImages.rawValue).child(imageName)
                
            imageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                if let err = error {
                    log.error("failed to save profile image", context: err)
                    return
                }
                
                imageRef.downloadURL(completion: { (url, error) in
                    if let err = error {
                        log.error("failed to get profile image url", context: err)
                        return
                    }
                    
                    guard let profileImageUrl = url?.absoluteString else { return }
                    let values = [uid: ["username": username, "profileImageUrl": profileImageUrl]]
                    
                    Database.database().reference().child(DBChild.users.rawValue).updateChildValues(values, withCompletionBlock: { (error, ref) in
                        if let err = error {
                            log.error("Failed to update user's profile image", context: err)
                            return
                        }
                        
                        self.dismiss(animated: true, completion: nil)
                    })
                })
            })
        }
    }
    
    @objc private func handleAlreadyHaveAccount(){
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleTextInputChange() {
        if isFormValid() {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = UIColor.darkerBlue
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.lighterBlue
        }
    }
    
    private func isFormValid() -> Bool {
        guard let email = emailTextField.text, email.count > 0, let username = usernameTextField.text, username.count > 0, let password = passwordTextField.text, password.count > 0 else { return false }
        return true
    }
}
