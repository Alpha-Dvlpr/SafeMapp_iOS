//
//  Request.swift
//  SafeMapp
//
//  Created by Aarón on 22/8/20.
//  Copyright © 2020 Aarón. All rights reserved.
//

import Foundation

class Request: NSObject {
    var userName: String
    var latitude: Double
    var longitude: Double
    var email: String
    var status: String
    var timestamp: CLong
    var userId: String
    var image: String
    var requestId: String
    
    init(userName: String, latitude: String, longitude: String, email: String, status: String,
         timestamp: CLong, userId: String, image: String, requestId: String) {
        self.userName = userName
        self.latitude = Double(latitude) ?? 0
        self.longitude = Double(longitude) ?? 0
        self.email = email
        self.status = status
        self.timestamp = timestamp
        self.userId = userId
        self.image = image
        self.requestId = requestId
    }
}
