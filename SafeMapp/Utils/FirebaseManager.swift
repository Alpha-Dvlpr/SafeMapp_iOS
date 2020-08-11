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
                //TODO: Create notification here and observer on registerVC
                print("FM | Error al registrar")
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
                    //TODO: Create notification here and observer on registerVC
                    print("FM | Error al guardar los datos en la bbdd")
                    return
                }
                
                //TODO: Create notification here and observer on registerVC
                print("FM | Datos guardados correctamente")
            })
        }
    }
}
