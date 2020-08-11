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
        view.placeholder = NSLocalizedString("email", comment: "")
        view.keyboardType = .emailAddress
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
        let rawText: String = NSLocalizedString("resetPasswordInfo", comment: "")
        let firstColoredText: String = NSLocalizedString("send", comment: "")
        let secondColoredText: String = NSLocalizedString("email", comment: "")
        let coloredText: NSAttributedString = rawText.attributedStringWithColor([firstColoredText, secondColoredText], color: AppColors.greenColor)
        
        view.attributedText = coloredText
        view.textAlignment = .left
        view.numberOfLines = 4
        view.font = .systemFont(ofSize: 12)
    
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
    
    @objc private func sendEmailButtonPressed() {
        if (self.emailTextField.text == "") {
            ToastNotification.shared.long(view, txt_msg: NSLocalizedString("emailRequired", comment: ""))
        } else {
            //TODO: make send email stuff
            ToastNotification.shared.long(view, txt_msg: "\(NSLocalizedString("emailSent", comment: "")) '\(self.emailTextField.text!)'")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func cancelButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
}
