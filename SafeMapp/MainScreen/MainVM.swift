//
//  MainVM.swift
//  SafeMapp
//
//  Created by Aarón on 22/8/20.
//  Copyright © 2020 Aarón. All rights reserved.
//

import Foundation
import MapKit

class MainVM {
    var requests: [Request] = []
    var nearUsers: [User] = []
    var allUsers: [User] = []
    var userLocation: CLLocation!
    let maxDistance: Double = 1000
    var usersFetched: Bool = false
    
    init() {
        self.addNotificationObservers()
        FirebaseManager.getRequests()
    }
    
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(userDidSetupLocation(_:)), name: Notification.Name(rawValue: Notifications.userDidSetupLocation), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userDidSetupLocation(_:)), name: NSNotification.Name(rawValue: Notifications.userDidChangeLocation), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getUsersSuccessEvent(_:)), name: Notification.Name(rawValue: Notifications.getUsersSuccess), object: nil)
    }
    
    @objc private func userDidSetupLocation(_ notification: NSNotification) {
        if let info = notification.userInfo {
            if let location: CLLocation = info["location"] as? CLLocation {
                self.userLocation = location
            }
        }
        
        FirebaseManager.getUsers()
    }
    
    @objc private func userDidChangeLocationEvent(_ notification: NSNotification) {
        if let info = notification.userInfo {
            if let location: CLLocation = info["location"] as? CLLocation {
                self.userLocation = location
                self.getNearUsers()
            }
        }
    }
    
    @objc private func getUsersSuccessEvent(_ notification: NSNotification) {
        if let info = notification.userInfo {
            if let users: [User] = info["users"] as? [User] {
                self.allUsers = users
                self.getNearUsers()
            }
        }
    }
    
    private func getNearUsers() {
        if self.userLocation != nil {
            self.nearUsers.removeAll()
            
            for user in allUsers {
                let auxLocation = CLLocation(latitude: user.latitude, longitude: user.longitude)
                
                if userLocation.distance(from: auxLocation) <= self.maxDistance {
                    self.nearUsers.append(user)
                }
            }
            
            self.usersFetched = true
        } else {
            self.usersFetched = false
        }
        
        NotificationCenter.default.post(Notification(name: Notification.Name(Notifications.usersFiltered)))
    }
}
