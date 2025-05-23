//
//  ForgotPasswordVC.swift
//  SafeMapp
//
//  Created by Aarón on 6/8/20.
//  Copyright © 2020 Aarón. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {

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
        view.keyboardType = .emailAddress
        view.textColor = .black
        view.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("email", comment: ""),
            attributes: [.foregroundColor: UIColor.lightGray]
        )
        return view
    }()
    
    let sendButton: UIButton = {
        let view = UIButton()
        view.setTitle(NSLocalizedString("send", comment: ""), for: .normal)
        view.backgroundColor = AppColors.greenColor
        return view
    }()
    
    let cancelButton: UIButton = {
        let view = UIButton()
        view.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
        view.backgroundColor = AppColors.redColor
        return view
    }()
    
    let infoLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.numberOfLines = 4
        view.text = NSLocalizedString("resetPasswordInfo", comment: "")
        view.textColor = .black
        view.font = .systemFont(ofSize: 12)
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
        NotificationCenter.default.addObserver(self, selector: #selector(recoveryEmailErrorEvent), name: Notification.Name(rawValue: Notifications.recoveryEmailError), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sendRecoveryEmailEvent), name: Notification.Name(rawValue: Notifications.sendRecoveryEmail), object: nil)
    }
    
    @objc private func recoveryEmailErrorEvent() {
        ToastNotification.shared.long(view, txt_msg: NSLocalizedString("recoveryEmailError", comment: ""))
    }
    
    @objc private func sendRecoveryEmailEvent() {
        ToastNotification.shared.long(view, txt_msg: "\(NSLocalizedString("emailSent", comment: "")) '\(self.emailTextField.text!)'")
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (timer) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func addViews() {
        view.addSubview(backgroundImage)
        view.addSubview(logoImage)
        view.addSubview(logoName)
        view.addSubview(emailTextField)
        view.addSubview(infoLabel)
        view.addSubview(sendButton)
        view.addSubview(cancelButton)
        
        [
            emailTextField
        ].forEach { (view) in
            view.setBottomBorder()
            view.contentVerticalAlignment = .center
            view.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: view.frame.height))
            view.leftViewMode = .always
        }
        
        [
            sendButton,
            cancelButton
        ].forEach { (view) in
            view.layer.cornerRadius = 15
            view.setTitleColor(.white, for: .normal)
            view.titleLabel?.font = .systemFont(ofSize: 13)
        }
        
        sendButton.addTarget(self, action: #selector(sendEmailButtonPressed), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
    }
    
    @objc private func sendEmailButtonPressed() {
        guard let email = self.emailTextField.text else {
            return
        }
        
        if email == "" {
            ToastNotification.shared.long(view, txt_msg: NSLocalizedString("emailRequired", comment: ""))
        } else {
            FirebaseManager.sendRecoverPasswordEmail(
                email: email,
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
            emailTextField,
            infoLabel,
            sendButton,
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
        
        emailTextField.topAnchor.constraint(equalTo: logoName.bottomAnchor, constant: 64).isActive = true
        emailTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24).isActive = true
        emailTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        infoLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 32).isActive = true
        infoLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24).isActive = true
        infoLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        
        sendButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 32).isActive = true
        sendButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24).isActive = true
        sendButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        cancelButton.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 12).isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
}
