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
import FirebaseMessaging

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
            let tokenId = Messaging.messaging().fcmToken
            let userInfo = [ "token_id": tokenId ]
            
            databaseReference.child(usersReference).child(currentUser!).updateChildValues(userInfo as [AnyHashable : Any], withCompletionBlock: { (databaseError, reference) in
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
    
    static func getMyself() {
        let currentUser = Auth.auth().currentUser?.uid
        
        databaseReference.child(usersReference).child(currentUser!).observeSingleEvent(
            of: .value,
            with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                
                let mySelf = User(
                    name: value?["userName"] as? String ?? "none",
                    email: value?["email"] as? String ?? "none",
                    latitude: value?["latitude"] as? Double ?? 0,
                    longitude: value?["longitude"] as? Double ?? 0,
                    id: value?["userId"] as? String ?? "none",
                    image: value?["image"] as? String ?? "none",
                    token: value?["token_id"] as? String ?? "none"
                )
                
                let info: [String: User] = [ "myself": mySelf ]
                
                NotificationCenter.default.post(
                    name: NSNotification.Name(rawValue: Notifications.getMyself),
                    object: nil,
                    userInfo: info
                )
            }
        ) { (error) in }
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
        
        databaseReference.child(requestsReference).child(currentUser!).queryOrdered(byChild: "status").queryEqual(toValue: "pending").observe(.value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            var requests: [Request] = []
            
            if value != nil {
                for val in (value?.allValues)! {
                    let aux = val as! NSDictionary
                    let request = Request(
                        userName: aux["userName"] as? String ?? "none",
                        latitude: aux["latitude"] as? String ?? "none",
                        longitude: aux["longitude"] as? String ?? "none",
                        email: aux["email"] as? String ?? "none",
                        status: aux["status"] as? String ?? "none",
                        timestamp: aux["timestamp"] as? Int ?? 0,
                        userId: aux["userId"] as? String ?? "none",
                        image: aux["image"] as? String ?? "none",
                        requestId: aux["requestId"] as? String ?? "none"
                    )
                    
                    requests.append(request)
                }
            }
            
            let info: [String: [Request]] = ["requests": requests]
            
            NotificationCenter.default.post(
                name: NSNotification.Name(Notifications.getRequestsSuccess),
                object: nil,
                userInfo: info
            )
        }
    }
    
    static func getUsers() {
        let currentUserId = Auth.auth().currentUser?.uid
        
        databaseReference.child(usersReference).observe(.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            var users: [User] = []
            
            if value != nil {
                for val in (value?.allValues)! {
                    let aux = val as! NSDictionary
                    let userId = aux["userId"] as? String ?? "none"
                    
                    if userId != currentUserId {
                        let user = User(
                            name: aux["userName"] as? String ?? "none",
                            email: aux["email"] as? String ?? "none",
                            latitude: aux["latitude"] as? Double ?? 0,
                            longitude: aux["longitude"] as? Double ?? 0,
                            id: userId,
                            image: aux["image"] as? String ?? "none",
                            token: aux["token_id"] as? String ?? "none"
                        )
                        
                        users.append(user)
                    }
                }
            }
            
            let info: [String: [User]] = [ "users": users ]
            
            NotificationCenter.default.post(
                name: NSNotification.Name(Notifications.getUsersSuccess),
                object: nil,
                userInfo: info
            )
        })
    }
    
    static func sendNotification(users: [User], myself: User) {
        print("myself token: \(myself.token)")
        
        for user in users {
            let notificationValue = [
                "notification" : "\(user.userName) \(NSLocalizedString("somebodyIsInTroubleShort", comment: ""))",
                "userId" : user.userId
            ]
            databaseReference.child(notificationsReference).child(user.userId).setValue(notificationValue)
            
            //TODO: Delete above this when android version is fixed
            
            let childRef = databaseReference.child(requestsReference).child(user.userId).childByAutoId().key
            let requestValue = [
                "userName": myself.userName,
                "latitude": myself.latitude,
                "longitude": myself.longitude,
                "email": myself.email,
                "status": "pending",
                "timestamp": ServerValue.timestamp(),
                "userId": myself.userId,
                "image": myself.image,
                "requestId": childRef!
            ] as [String: Any]
            databaseReference.child(requestsReference).child(user.userId).child(childRef!).setValue(requestValue)
    
            print("token: \(user.token)")
            
            if user.token != "none" {
                let sender = PushNotificationSender()
                sender.sendPushNotification(
                    to: user.token,
                    title: NSLocalizedString("somebodyIsInTrouble", comment: ""),
                    body: "\(myself.userName) \(NSLocalizedString("somebodyIsInTroubleShort", comment: ""))"
                )
            }
        }
    }
    
    static func ignoreRequest(request: Request) {
        let currentUser = Auth.auth().currentUser?.uid
        let values: [String: String] = [ "status" : "ignored" ]
        
        databaseReference.child(requestsReference).child(currentUser!).child(request.requestId).updateChildValues(values)
    }
    
    static func acceptRequest(request: Request, user: User, myself: User) {
        let currentUser = Auth.auth().currentUser?.uid
        let values: [String: String] = [ "status" : "accepter" ]
        
        databaseReference.child(requestsReference).child(currentUser!).child(request.requestId).updateChildValues(values)
        
        if user.token != "none" {
            let sender = PushNotificationSender()
            sender.sendPushNotification(
                to: user.token,
                title: "Solicitud aceptada",
                body: "\(myself.userName) \(NSLocalizedString("onTheWay", comment: ""))")
        }
    }
}
