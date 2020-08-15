//
//  FirebaseManager.swift
//  SafeMapp
//
//  Created by Aarón on 11/8/20.
//  Copyright © 2020 Aarón. All rights reserved.
//

import FirebaseAuth
import FirebaseDatabase
import MBProgressHUD

class FirebaseManager {
    private static let databaseReference = Database.database().reference(fromURL: "https://safemapp-8c432.firebaseio.com/")
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
}
