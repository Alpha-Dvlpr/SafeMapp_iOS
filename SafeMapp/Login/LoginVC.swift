//
//  LoginVC.swift
//  SafeMapp
//
//  Created by Aarón on 5/8/20.
//  Copyright © 2020 Aarón. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    let logoImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "logo")
        return view
    }()
    
    let logoName: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "name")
        return view
    }()
    
    let backgroundImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "background")
        return view
    }()
    
    let emailTextField: UITextField = {
        let view = UITextField()
        view.placeholder = NSLocalizedString("email", comment: "")
        view.keyboardType = .emailAddress
        return view
    }()
    
    let passwordTextField: UITextField = {
        let view = UITextField()
        view.placeholder = NSLocalizedString("password", comment: "")
        view.isSecureTextEntry = true
        return view
    }()
    
    let forgottenPasswordLabel: UILabel = {
        let view = UILabel()
        view.text = NSLocalizedString("forgottenPassword", comment: "")
        view.font = .systemFont(ofSize: 12)
        view.textAlignment = .right
        return view
    }()
    
    let loginButton: UIButton = {
        let view = UIButton()
        view.setTitle(NSLocalizedString("login", comment: ""), for: .normal)
        view.backgroundColor = UIColor(red: 8/255, green: 149/255, blue: 68/255, alpha: 1.0)
        return view
    }()
    
    let registerButton: UIButton = {
        let view = UIButton()
        view.setTitle(NSLocalizedString("register", comment: ""), for: .normal)
        view.backgroundColor = UIColor(red: 201/255, green: 2/255, blue: 2/255, alpha: 1.0)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        self.addViews()
        self.setupConstraints()
    }
    
    private func addViews() {
        view.addSubview(backgroundImage)
        view.addSubview(logoImage)
        view.addSubview(logoName)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(forgottenPasswordLabel)
        view.addSubview(loginButton)
        view.addSubview(registerButton)
        
        [
            emailTextField,
            passwordTextField
        ].forEach { (view) in
            view.setBottomBorder()
            view.contentVerticalAlignment = .center
            view.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: view.frame.height))
            view.leftViewMode = .always
        }
        
        [
            loginButton,
            registerButton
        ].forEach { (view) in
            view.layer.cornerRadius = 15
            view.setTitleColor(.white, for: .normal)
            view.titleLabel?.font = .systemFont(ofSize: 13)
        }
        
        forgottenPasswordLabel.isUserInteractionEnabled = true
        forgottenPasswordLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(forgottenPasswordLabelPressed)))
        
        loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerButtonPressed), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        [
            backgroundImage,
            logoImage,
            logoName,
            emailTextField,
            passwordTextField,
            forgottenPasswordLabel,
            loginButton,
            registerButton
        ].forEach { (view) in
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        backgroundImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        backgroundImage.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        backgroundImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        backgroundImage.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        
        logoImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        logoImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        logoImage.widthAnchor.constraint(equalToConstant: 72).isActive = true
        logoImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        logoName.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: 20).isActive = true
        logoName.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        logoName.heightAnchor.constraint(equalToConstant: 30).isActive = true
        logoName.widthAnchor.constraint(equalToConstant: 167).isActive = true
        
        emailTextField.topAnchor.constraint(equalTo: logoName.bottomAnchor, constant: 64).isActive = true
        emailTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24).isActive = true
        emailTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
    
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 12).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        forgottenPasswordLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 12).isActive = true
        forgottenPasswordLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24).isActive = true
        forgottenPasswordLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        
        loginButton.topAnchor.constraint(equalTo: forgottenPasswordLabel.bottomAnchor, constant: 32).isActive = true
        loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24).isActive = true
        loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 12).isActive = true
        registerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24).isActive = true
        registerButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 41).isActive = true
    }
    
    @objc private func forgottenPasswordLabelPressed() {
        print("olvidaste la contraseña")
    }
    
    @objc private func loginButtonPressed() {
        print("iniciaste sesión")
    }
    
    @objc private func registerButtonPressed() {
        print("te has registrado")
    }
}
