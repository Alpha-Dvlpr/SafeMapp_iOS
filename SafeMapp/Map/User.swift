//
//  User.swift
//  SafeMapp
//
//  Created by Aarón on 23/8/20.
//  Copyright © 2020 Aarón. All rights reserved.
//

import Foundation

class User: NSObject {
    var userName: String
    var email: String
    var latitude: Double
    var longitude: Double
    var userId: String
    var image: String
    var token: String
    
    init(name: String, email: String, latitude: Double, longitude: Double, id: String, image: String, token: String) {
        self.userName = name
        self.email = email
        self.latitude = latitude
        self.longitude = longitude
        self.userId = id
        self.image = image
        self.token = token
    }
}
