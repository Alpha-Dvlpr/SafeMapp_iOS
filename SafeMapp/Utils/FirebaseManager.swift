//
//  FirebaseManager.swift
//  SafeMapp
//
//  Created by Aarón on 11/8/20.
//  Copyright © 2020 Aarón. All rights reserved.
//

import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import MBProgressHUD

class FirebaseManager {
    private static let databaseReference = Database.database().reference(fromURL: "https://safemapp-8c432.firebaseio.com/")
    private static let storageReference = Storage.storage().reference()
    private static let usersReference = "Users"
    private static let notificationsReference = "Notifications"
    private static let requestsReference = "Request"
    
    static func registerNewUser(email: String, password: String, nickname: String, onView: UIView) {
        let hud = MBProgressHUD.showAdded(to: onView, animated: true)
        hud.mode = .indeterminate
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if error != nil {
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Notifications.registerError)))
                hud.hide(animated: true)
                return
            }
            
            let currentUser = Auth.auth().currentUser?.uid
            let userInfo = [
                "userName": nickname,
                "email": email,
                "userId": currentUser!
            ]
            
            databaseReference.child(usersReference).child(currentUser!).updateChildValues(userInfo, withCompletionBlock: { (databaseError, reference) in
                if databaseError != nil {
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Notifications.saveDataError)))
                    hud.hide(animated: true)
                    return
                }
                
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Notifications.registerSuccess)))
                hud.hide(animated: true)
                
                do {
                    try Auth.auth().signOut()
                } catch { }
            })
        }
    }
    
    static func sendRecoverPasswordEmail(email: String, onView: UIView) {
        let hud = MBProgressHUD.showAdded(to: onView, animated: true)
        hud.mode = .indeterminate
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error != nil {
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Notifications.recoveryEmailError)))
                hud.hide(animated: true)
                return
            }
            
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Notifications.sendRecoveryEmail)))
            hud.hide(animated: true)
        }
    }
    
    static func loginUser(email: String, password: String, onView: UIView) {
        let hud = MBProgressHUD.showAdded(to: onView, animated: true)
        hud.mode = .indeterminate
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Notifications.loginError)))
                hud.hide(animated: true)
                return
            }
            
            let currentUser = Auth.auth().currentUser?.uid
            let tokenId = "" //TODO: Configure cloud messaging
            let userInfo = [
                "token_id": tokenId
            ]
            
            databaseReference.child(usersReference).child(currentUser!).updateChildValues(userInfo, withCompletionBlock: { (databaseError, reference) in
                if databaseError != nil {
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Notifications.saveDataError)))
                    hud.hide(animated: true)
                    return
                }
                
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Notifications.loginSuccess)))
                hud.hide(animated: true)
            })
        }
    }
    
    static func getAuth() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    static func logOut(onView: UIView) {
        let hud = MBProgressHUD.showAdded(to: onView, animated: true)
        hud.mode = .indeterminate
        
        do {
            try Auth.auth().signOut()
        } catch {
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Notifications.logoutError)))
            hud.hide(animated: true)
            return
        }
        
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Notifications.logoutSuccess)))
        hud.hide(animated: true)
    }
    
    static func getUserInfo(onView: UIView) {
        let currentUser = Auth.auth().currentUser?.uid
        let hud = MBProgressHUD.showAdded(to: onView, animated: true)
        hud.mode = .indeterminate
        
        databaseReference.child(usersReference).child(currentUser!).observeSingleEvent(
            of: .value,
            with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let userData: [String: String] = [
                    "nick": value?["userName"] as? String ?? "none",
                    "mail": value?["email"] as? String ?? "none",
                    "photo": value?["image"] as? String ?? "none"
                ]
                
                NotificationCenter.default.post(
                    name: Notification.Name(rawValue: Notifications.getUserInfoSuccess),
                    object: nil,
                    userInfo: userData
                )
                hud.hide(animated: true)
            }) { (error) in
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Notifications.getUserInfoError)))
                hud.hide(animated: true)
            }
    }
    
    static func updateUserLocation(longitude: Double, latitude: Double) {
        let currentuser = Auth.auth().currentUser?.uid
        let userInfo: [String: Double] = [
            "latitude": latitude,
            "longitude": longitude
        ]
        
        databaseReference.child(usersReference).child(currentuser!).updateChildValues(userInfo)
    }
    
    static func uploadUserImage(onView: UIView, nickname: String, image: UIImage? = nil) {
        let currentUser = Auth.auth().currentUser?.uid
        let hud = MBProgressHUD.showAdded(to: onView, animated: true)
        hud.mode = .indeterminate
        
        if image != nil {
            let imageReference = storageReference.child(usersReference).child("\(currentUser!).jpeg")
            imageReference.putData(
                image!.jpegData(compressionQuality: 0.8)!,
                metadata: nil
            ) { (metadata, error) in
                if error != nil {
                    let userInfo: [String: String] = [ "userName" : nickname ]
                    
                    self.updateUserInformation(onView: onView, userInfo: userInfo)
                    hud.hide(animated: true)
                    return
                }
                
                imageReference.downloadURL(completion: { (url, error) in
                    guard let downloadURL = url else {
                        let userInfo: [String: String] = [ "userName" : nickname ]
                        
                        self.updateUserInformation(onView: onView, userInfo: userInfo)
                        hud.hide(animated: true)
                        return
                    }
                    
                    let userInfo: [String: String] = [
                        "userName": nickname,
                        "image": downloadURL.absoluteString
                    ]
                    
                    self.updateUserInformation(onView: onView, userInfo: userInfo)
                    hud.hide(animated: true)
                })
            }
        } else {
            let userInfo: [String: String] = [ "userName" : nickname ]
            
            self.updateUserInformation(onView: onView, userInfo: userInfo)
            hud.hide(animated: true)
        }
    }
    
    private static func updateUserInformation(onView: UIView, userInfo: [String: String]) {
        let currentUser = Auth.auth().currentUser?.uid
        let hud = MBProgressHUD.showAdded(to: onView, animated: true)
        hud.mode = .indeterminate
        
        databaseReference.child(usersReference).child(currentUser!).updateChildValues(userInfo) { (error, reference) in
            if error != nil {
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Notifications.updateUserInfoError)))
                hud.hide(animated: true)
                return
            }
            
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Notifications.updateUserInfoSuccess)))
            hud.hide(animated: true)
        }
    }
    
    static func getRequests() {
        let currentUser = Auth.auth().currentUser?.uid
        
        //TODO: Get requests
    }
    
    static func getUsers() {
        
    }
}
