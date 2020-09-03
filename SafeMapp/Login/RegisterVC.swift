//
//  RegisterVC.swift
//  SafeMapp
//
//  Created by Aarón on 6/8/20.
//  Copyright © 2020 Aarón. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController {

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
    
    let usernameTextField: UITextField = {
        let view = UITextField()
        view.keyboardType = .default
        view.textColor = .black
        view.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("username", comment: ""),
            attributes: [.foregroundColor: UIColor.lightGray]
        )
        return view
    }()
    
    let emailTextField: UITextField = {
        let view = UITextField()
        view.keyboardType = .emailAddress
        view.textColor = .black
        view.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("email", comment: ""),
            attributes: [.foregroundColor: UIColor.lightGray]
        )
        return view
    }()
    
    let passwordTextField: UITextField = {
        let view = UITextField()
        view.isSecureTextEntry = true
        view.textColor = .black
        view.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("password", comment: ""),
            attributes: [.foregroundColor: UIColor.lightGray]
        )
        return view
    }()
    
    let createAccountButton: UIButton = {
        let view = UIButton()
        view.setTitle(NSLocalizedString("createAccount", comment: ""), for: .normal)
        view.backgroundColor = AppColors.greenColor
        return view
    }()
    
    let cancelButton: UIButton = {
        let view = UIButton()
        view.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
        view.backgroundColor = AppColors.redColor
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        self.addNotificationListeners()
        self.addViews()
        self.setupConstraints()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func addNotificationListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(registerErrorEvent), name: Notification.Name(rawValue: Notifications.registerError), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(registerSuccessEvent), name: Notification.Name(rawValue: Notifications.registerSuccess), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(saveDataErrorEvent), name: Notification.Name(rawValue: Notifications.saveDataError), object: nil)
    }
    
    @objc private func registerErrorEvent() {
        ToastNotification.shared.long(view, txt_msg: NSLocalizedString("registerError", comment: ""))
    }
    
    @objc private func registerSuccessEvent() {
        ToastNotification.shared.long(view, txt_msg: NSLocalizedString("registerSuccess", comment: ""))
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (timer) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func saveDataErrorEvent() {
        ToastNotification.shared.long(view, txt_msg: NSLocalizedString("dataSaveError", comment: ""))
    }
    
    private func addViews() {
        view.addSubview(backgroundImage)
        view.addSubview(logoImage)
        view.addSubview(logoName)
        view.addSubview(usernameTextField)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(createAccountButton)
        view.addSubview(cancelButton)
        
        [
            usernameTextField,
            emailTextField,
            passwordTextField
        ].forEach { (view) in
            view.setBottomBorder()
            view.contentVerticalAlignment = .center
            view.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: view.frame.height))
            view.leftViewMode = .always
        }
        
        [
            createAccountButton,
            cancelButton
        ].forEach { (view) in
            view.layer.cornerRadius = 15
            view.setTitleColor(.white, for: .normal)
            view.titleLabel?.font = .systemFont(ofSize: 13)
        }
        
        createAccountButton.addTarget(self, action: #selector(createAccountButtonPressed), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
    }
    
    @objc private func createAccountButtonPressed() {
        guard let email = self.emailTextField.text, let password = self.passwordTextField.text, let nickname = self.usernameTextField.text else {
            return
        }
        
        if email == "" || password == "" || nickname == "" {
            ToastNotification.shared.long(view, txt_msg: NSLocalizedString("allFieldsRequired", comment: ""))
        }else {
            FirebaseManager.registerNewUser(
                email: email,
                password: password,
                nickname: nickname,
                onView: view
            )
        }
    }
    
    @objc private func cancelButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupConstraints() {
        [
            backgroundImage,
            logoImage,
            logoName,
            usernameTextField,
            emailTextField,
            passwordTextField,
            createAccountButton,
            cancelButton
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
        
        usernameTextField.topAnchor.constraint(equalTo: logoName.bottomAnchor, constant: 64).isActive = true
        usernameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24).isActive = true
        usernameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        usernameTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        emailTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 12).isActive = true
        emailTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24).isActive = true
        emailTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 12).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        createAccountButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 32).isActive = true
        createAccountButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24).isActive = true
        createAccountButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        createAccountButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        cancelButton.topAnchor.constraint(equalTo: createAccountButton.bottomAnchor, constant: 12).isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
}
