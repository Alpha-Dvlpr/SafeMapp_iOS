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
    
    //imageview con imagen cargada y tap gesture para ambiar, permisos
    //campo de texto para nickname
    //campo de texto para email
    //variable para detectar cambios
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        self.addNotificationObservers()
        self.addViews()
        self.setupConstraints()
        self.getAndSetData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(getUserInfoErrorEvent), name: NSNotification.Name(rawValue: Notifications.getUserInfoError), object: nil)
    }
    
    private func addViews() {
        view.addSubview(backgroundImage)
        view.addSubview(logoImage)
        view.addSubview(logoName)
        view.addSubview(userImage)
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
        
        updateProfileButton.isEnabled = changesMade
        updateProfileButton.backgroundColor = changesMade ? AppColors.greenColor : AppColors.grayColor
        
        userImage.isUserInteractionEnabled = true
        
        userImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userImageTapped)))
        updateProfileButton.addTarget(self, action: #selector(updateProfileButtonPressed), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        [
            backgroundImage,
            logoImage,
            logoName,
            userImage,
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
    
    private func getAndSetData() {
//        let userInfo = FirebaseManager.getUserInfo(onView: view)
//        
//        if userInfo.count == 0 {
//            ToastNotification.shared.long(view, txt_msg: "No hay na")
//        } else {
//            self.usernameTextField.text = userInfo[0]
//            self.emailTextField.text = userInfo[1]
//        }
    }
    
    @objc private func getUserInfoErrorEvent() {
        ToastNotification.shared.long(view, txt_msg: "Error al obtener los datos del usuarion")
    }
    
    @objc private func userImageTapped() {
        print("image pressed")
        self.changesMade.toggle()
        
        self.updateProfileButton.isEnabled = self.changesMade
        self.updateProfileButton.backgroundColor = self.changesMade ? AppColors.greenColor : AppColors.grayColor
    }
    
    @objc private func updateProfileButtonPressed() {
        print("updating profile")
    }
    
    @objc private func cancelButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
}
