//
//  ProfileVC.swift
//  SafeMapp
//
//  Created by Aarón on 15/8/20.
//  Copyright © 2020 Aarón. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {

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
    
    let userImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "profile")
        return view
    }()
    
    let addImageButton: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "addimage")
        view.tintColor = AppColors.greenColor
        return view
    }()
    
    let usernameTextField: UITextField = {
        let view = UITextField()
        view.placeholder = NSLocalizedString("username", comment: "")
        view.keyboardType = .default
        return view
    }()
    
    let emailTextField: UITextField = {
        let view = UITextField()
        view.placeholder = NSLocalizedString("email", comment: "")
        view.keyboardType = .emailAddress
        return view
    }()
    
    let updateProfileButton: UIButton = {
        let view = UIButton()
        view.setTitle(NSLocalizedString("updateProfile", comment: ""), for: .normal)
        view.backgroundColor = AppColors.greenColor
        return view
    }()
    
    let cancelButton: UIButton = {
        let view = UIButton()
        view.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
        view.backgroundColor = AppColors.redColor
        return view
    }()
    
    var changesMade: Bool = false
    var userInfo: [String]!
    var originalNickname: String!
    var newNickname: String!
    var imageChanged: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        self.addNotificationObservers()
        self.addViews()
        self.setupConstraints()
        self.checkChanges()
        
        FirebaseManager.getUserInfo(onView: view)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(getUserInfoErrorEvent), name: NSNotification.Name(rawValue: Notifications.getUserInfoError), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getUserInfoSuccessEvent(_:)), name: NSNotification.Name(rawValue: Notifications.getUserInfoSuccess), object: nil)
    }
    
    private func addViews() {
        view.addSubview(backgroundImage)
        view.addSubview(logoImage)
        view.addSubview(logoName)
        view.addSubview(userImage)
        view.addSubview(addImageButton)
        view.addSubview(usernameTextField)
        view.addSubview(emailTextField)
        view.addSubview(updateProfileButton)
        view.addSubview(cancelButton)
        
        [
            usernameTextField,
            emailTextField
        ].forEach { (view) in
            view.setBottomBorder()
            view.contentVerticalAlignment = .center
            view.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: view.frame.height))
            view.leftViewMode = .always
        }
        
        [
            updateProfileButton,
            cancelButton
        ].forEach { (view) in
            view.layer.cornerRadius = 15
            view.setTitleColor(.white, for: .normal)
            view.titleLabel?.font = .systemFont(ofSize: 13)
        }
        
        userImage.isUserInteractionEnabled = true
        addImageButton.isUserInteractionEnabled = true
        emailTextField.isEnabled = false
        
        userImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userImageTapped)))
        addImageButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userImageTapped)))
        updateProfileButton.addTarget(self, action: #selector(updateProfileButtonPressed), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        usernameTextField.addTarget(self, action: #selector(nicknameChangedEvent(_:)), for: .editingChanged)
    }
    
    private func setupConstraints() {
        [
            backgroundImage,
            logoImage,
            logoName,
            userImage,
            addImageButton,
            usernameTextField,
            emailTextField,
            updateProfileButton,
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
        
        userImage.topAnchor.constraint(equalTo: logoName.bottomAnchor, constant: 24).isActive = true
        userImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        userImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        userImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        userImage.layer.cornerRadius = 50
        
        addImageButton.bottomAnchor.constraint(equalTo: userImage.bottomAnchor, constant: 0).isActive = true
        addImageButton.trailingAnchor.constraint(equalTo: userImage.trailingAnchor, constant: 0).isActive = true
        addImageButton.widthAnchor.constraint(equalToConstant: 33).isActive = true
        addImageButton.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        usernameTextField.topAnchor.constraint(equalTo: userImage.bottomAnchor, constant: 32).isActive = true
        usernameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24).isActive = true
        usernameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        usernameTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        emailTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 12).isActive = true
        emailTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24).isActive = true
        emailTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        updateProfileButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 32).isActive = true
        updateProfileButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24).isActive = true
        updateProfileButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        updateProfileButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        cancelButton.topAnchor.constraint(equalTo: updateProfileButton.bottomAnchor, constant: 12).isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    private func checkChanges() {
        self.changesMade = (self.imageChanged || (self.originalNickname != self.newNickname))
        
        updateProfileButton.isEnabled = changesMade
        updateProfileButton.backgroundColor = changesMade ? AppColors.greenColor : AppColors.grayColor
    }
    
    @objc private func getUserInfoErrorEvent() {
        ToastNotification.shared.long(view, txt_msg: "Error al obtener los datos del usuarion")
    }
    
    @objc private func getUserInfoSuccessEvent(_ notification: NSNotification) {
        if let userData = notification.userInfo as NSDictionary? {
            if let nick = userData["nick"], let mail = userData["mail"], let photo = userData["photo"] {
                self.usernameTextField.text = nick as? String
                self.emailTextField.text = mail as? String
                
                self.originalNickname = nick as? String
                self.newNickname = nick as? String
                
                if photo as? String != "none" {
                    print("\(photo)")
                }
            }
        }
    }
    
    @objc private func userImageTapped() {
        
        
        
        
        
        
        self.imageChanged.toggle()
        self.checkChanges()
    }
    
    @objc private func nicknameChangedEvent(_ textField: UITextField) {
        self.newNickname = textField.text
        self.checkChanges()
    }
    
    @objc private func updateProfileButtonPressed() {
        print("updating profile")
    }
    
    @objc private func cancelButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
}
