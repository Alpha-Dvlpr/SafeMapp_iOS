//
//  FirebaseManager.swift
//  SafeMapp
//
//  Created by Aarón on 11/8/20.
//  Copyright © 2020 Aarón. All rights reserved.
//

import FirebaseAuth
import FirebaseDatabase


class FirebaseManager {
    private static let databaseReference = Database.database().reference(fromURL: "https://safemapp-8c432.firebaseio.com/")
    private static let usersReference = "Users"
    private static let notificationsReference = "Notifications"
    private static let requestsReference = "Request"
    
    static func registerNewUser(email: String, password: String, nickname: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if error != nil {
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Notifications.registerError)))
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
                    return
                }
                
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Notifications.registerSuccess)))
                
                do {
                    try Auth.auth().signOut()
                } catch { }
            })
        }
    }
    
    static func sendRecoverPasswordEmail(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error != nil {
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Notifications.recoveryEmailError)))
                return
            }
            
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Notifications.sendRecoveryEmail)))
        }
    }
    
    static func loginUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Notifications.loginError)))
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
                    return
                }
                
                
            })
        }
    }
}
