//
//  LoginController.swift
//  InstegramFirebase
//
//  Created by Paul Dong on 24/02/18.
//  Copyright © 2018 Paul Dong. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    let logoContainerView: UIView = {
        let v = UIView()
        
        let logoIV = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white"))
        v.addSubview(logoIV)
        logoIV.anchor(topAnchor: nil, paddingTop: 0, bottomAnchor: nil, paddingBottom: 0, leftAnchor: nil, paddingLeft: 0, rightAnchor: nil, paddingRight: 0, widthConstant: 0, heightConstant: 0, centerXAnchor: v.centerXAnchor, paddingCenterX: 0, centerYAnchor: v.centerYAnchor, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
        
        v.backgroundColor = UIColor.rgb(red: 0, green: 120, blue: 175)
        return v
    }()
    
    lazy var emailTextField: UITextField = {
        return Helper.createTextField(placeholder: "Email", secured: false, selector: #selector(self.handleTextInputChange), target: self)
    }()
    
    lazy var passwordTextField: UITextField = {
        return Helper.createTextField(placeholder: "Password", secured: true, selector: #selector(self.handleTextInputChange), target: self)
    }()
    
    lazy var loginButton: UIButton = {
        let b = UIButton(type: .system)
        b.isEnabled = false
        b.setTitle("Login", for: .normal)
        b.backgroundColor = UIColor.lighterBlue
        b.layer.cornerRadius = 5
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        b.setTitleColor(.white, for: .normal)
        b.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return b
    }()
    
    let errorMessageLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14)
        l.textColor = .red
        l.numberOfLines = 0
        l.isHidden = true
        return l
    }()
    
    let dontHaveAccountButton: UIButton = {
        let b = UIButton(type: .system)
        //attributed title
        let attributedString = NSMutableAttributedString(string: "Don't have an account? ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray])
        attributedString.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedStringKey.foregroundColor : UIColor.darkerBlue, .font: UIFont.boldSystemFont(ofSize: 14)]))
        b.setAttributedTitle(attributedString, for: UIControlState.normal)
        
        b.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        navigationController?.navigationBar.barTintColor = .white
        view.backgroundColor = .white
        view.addSubview(logoContainerView)
        view.addSubview(dontHaveAccountButton)
        view.addSubview(errorMessageLabel)
        
        logoContainerView.anchor(topAnchor: view.topAnchor, paddingTop: 0, bottomAnchor: nil, paddingBottom: 0, leftAnchor: view.leftAnchor, paddingLeft: 0, rightAnchor: view.rightAnchor, paddingRight: 0, widthConstant: 0, heightConstant: 150, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
        
        setupStackView()
        
        dontHaveAccountButton.anchor(topAnchor: nil, paddingTop: 0, bottomAnchor: view.bottomAnchor, paddingBottom: 0, leftAnchor: view.leftAnchor, paddingLeft: 0, rightAnchor: view.rightAnchor, paddingRight: 0, widthConstant: 0, heightConstant: 50, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
        
        errorMessageLabel.anchor(topAnchor: loginButton.bottomAnchor, paddingTop: 40, bottomAnchor: nil, paddingBottom: 0, leftAnchor: loginButton.leftAnchor, paddingLeft: 0, rightAnchor: loginButton.rightAnchor, paddingRight: 0, widthConstant: 0, heightConstant: 0, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupStackView() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        
        view.addSubview(stackView)
        stackView.anchor(topAnchor: logoContainerView.bottomAnchor, paddingTop: 40, bottomAnchor: nil, paddingBottom: 0, leftAnchor: view.leftAnchor, paddingLeft: 40, rightAnchor: view.rightAnchor, paddingRight: -40, widthConstant: 0, heightConstant: 140, centerXAnchor: nil, paddingCenterX: 0, centerYAnchor: nil, paddingCenterY: 0, widthAnchor: nil, widthMultiplier: 0, heightAnchor: nil, heightMultiplier: 0)
    }
    
    private func isFormValid() -> Bool {
        guard let email = emailTextField.text, email.count > 0, let password = passwordTextField.text, password.count > 0 else { return false }
        return true
    }
    
    @objc private func handleShowSignUp(){
        let signUpController = SignUpController()
        navigationController?.pushViewController(signUpController, animated: true)
    }
    
    @objc private func handleLogin(){
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let err = error {
                print(err)
                self.errorMessageLabel.text = err.localizedDescription
                self.errorMessageLabel.isHidden = false
                return
            }
            
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
            
            mainTabBarController.setupViewControllers()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func handleTextInputChange() {
        if isFormValid() {
            loginButton.isEnabled = true
            loginButton.backgroundColor = UIColor.darkerBlue
        } else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor.lighterBlue
        }
    }
}
