//
//  ProfileVC.swift
//  SafeMapp
//
//  Created by Aarón on 15/8/20.
//  Copyright © 2020 Aarón. All rights reserved.
//

import UIKit
import AVKit
import Photos
import MBProgressHUD

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
    
    let versionLabel: UILabel = {
        let view = UILabel()
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        view.text = "\(NSLocalizedString("version", comment: "")): \(appVersion!)"
        view.font = .systemFont(ofSize: 12)
        return view
    }()
    
    var changesMade: Bool = false
    var userInfo: [String]!
    var originalNickname: String!
    var newNickname: String!
    var newImage: UIImage!
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
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserInfoErrorEvent), name: NSNotification.Name(rawValue: Notifications.updateUserInfoError), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserInfoSuccessEvent), name: NSNotification.Name(rawValue: Notifications.updateUserInfoSuccess), object: nil)
    }
    
    @objc private func getUserInfoErrorEvent() {
        ToastNotification.shared.long(view, txt_msg: NSLocalizedString("getUserInfoError", comment: ""))
    }
    
    @objc private func getUserInfoSuccessEvent(_ notification: NSNotification) {
        if let userData = notification.userInfo as NSDictionary? {
            if let nick = userData["nick"], let mail = userData["mail"], let photo = userData["photo"] {
                self.usernameTextField.text = nick as? String
                self.emailTextField.text = mail as? String
                
                self.originalNickname = nick as? String
                self.newNickname = nick as? String
                
                if photo as! String != "none" {
                    let url = URL(string: photo as! String)
                    
                    URLSession.shared.dataTask(with: url!) { (data, response, error) in
                        if error != nil {
                            ToastNotification.shared.long(self.view, txt_msg: NSLocalizedString("loadImageError", comment: ""))
                            return
                        }
                    
                        DispatchQueue.main.async {
                            self.userImage.image = UIImage(data: data!)
                        }
                    }.resume()
                }
            }
        }
    }
    
    @objc private func updateUserInfoErrorEvent() {
        ToastNotification.shared.long(view, txt_msg: NSLocalizedString("updateUserInfoError", comment: ""))
    }
    
    @objc private func updateUserInfoSuccessEvent() {
        ToastNotification.shared.long(view, txt_msg: NSLocalizedString("updateUserInfoSuccess", comment: ""))
        
        self.changesMade = false
        self.originalNickname = self.newNickname
        self.newImage = nil
        self.imageChanged = false
        
        self.checkChanges()
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
        view.addSubview(versionLabel)
        
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
    
    @objc private func userImageTapped() {
        let alert = UIAlertController(title: NSLocalizedString("changeProfileImageTitle", comment: ""), message: NSLocalizedString("changeProfileImageDescription", comment: ""), preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: NSLocalizedString("camera", comment: ""), style: .default) { (action) in self.checkCameraPermission() }
        let galleryAction = UIAlertAction(title: NSLocalizedString("gallery", comment: ""), style: .default) { (action) in self.checkGalleryPermission() }
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
        
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func updateProfileButtonPressed() {
        FirebaseManager.uploadUserImage(
            onView: view,
            nickname: self.newNickname == nil ? self.originalNickname : self.newNickname,
            image: self.newImage == nil ? nil : self.newImage
        )
    }
    
    @objc private func cancelButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func nicknameChangedEvent(_ textField: UITextField) {
        self.newNickname = textField.text
        self.checkChanges()
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
            cancelButton,
            versionLabel
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
        userImage.layer.masksToBounds = true
        
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
        
        versionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12).isActive = true
        versionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12).isActive = true
    }
    
    private func checkChanges() {
        self.changesMade = (self.imageChanged || (self.originalNickname != self.newNickname))
        
        updateProfileButton.isEnabled = changesMade
        updateProfileButton.backgroundColor = changesMade ? AppColors.greenColor : AppColors.grayColor
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted { self.openCamera() }
                else{ self.showAlert(message: NSLocalizedString("cameraDenied", comment: "")) }
            }
            break
        case .restricted:
            print("camera restricted")
            self.showAlert(message: NSLocalizedString("cameraRestricted", comment: ""))
            break
        case .denied:
            print("camera denied")
            self.showAlert(message: NSLocalizedString("cameraDenied", comment: ""))
            break
        case .authorized:
            self.openCamera()
            break
        }
    }
    
    private func checkGalleryPermission() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized { self.openGallery() }
                else { self.showAlert(message: NSLocalizedString("galleryDenied", comment: "")) }
            }
            break
        case .restricted:
            self.showAlert(message: NSLocalizedString("galleryRestricted", comment: ""))
            break
        case .denied:
            self.showAlert(message: NSLocalizedString("galleryDenied", comment: ""))
            break
        case .authorized:
            self.openGallery()
            break
        }
    }
    
    private func openCamera() {
        let cameraController = UIImagePickerController()
        cameraController.sourceType = .camera
        cameraController.allowsEditing = true
        cameraController.delegate = self
        
        self.present(cameraController, animated: true)
    }
    
    private func openGallery() {
        let galleryController = UIImagePickerController()
        galleryController.sourceType = .photoLibrary
        galleryController.allowsEditing = true
        galleryController.delegate = self
        
        self.present(galleryController, animated: true)
    }
    
    private func showAlert(message: String) {
        let alertController = UIAlertController(title: NSLocalizedString("info", comment: ""), message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: NSLocalizedString("accept", comment: ""), style: .default, handler: nil)
        
        alertController.addAction(okButton)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ProfileVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.editedImage] as? UIImage else { return }
        
        self.userImage.image = image
        self.newImage = image
        self.imageChanged = true
        self.checkChanges()
    }
}
