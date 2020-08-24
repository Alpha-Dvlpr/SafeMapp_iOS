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
    var requestsFetched: Bool = false
    
    init() {
        self.addNotificationObservers()
        FirebaseManager.getRequests()
    }
    
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(userDidSetupLocation(_:)), name: Notification.Name(rawValue: Notifications.userDidSetupLocation), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userDidSetupLocation(_:)), name: NSNotification.Name(rawValue: Notifications.userDidChangeLocation), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getUsersSuccessEvent(_:)), name: Notification.Name(rawValue: Notifications.getUsersSuccess), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getRequestsSuccess(_:)), name: NSNotification.Name(rawValue: Notifications.getRequestsSuccess), object: nil)
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
                self.allUsers.removeAll()
                self.userLocation = location
                self.getNearUsers()
            }
        }
    }
    
    @objc private func getUsersSuccessEvent(_ notification: NSNotification) {
        if let info = notification.userInfo {
            if let users: [User] = info["users"] as? [User] {
                self.allUsers.removeAll()
                self.allUsers = users
                self.getNearUsers()
            }
        }
    }
    
    @objc private func getRequestsSuccess(_ notification: NSNotification) {
        if let info = notification.userInfo {
            if let requests: [Request] = info["requests"] as? [Request] {
                self.requests.removeAll()
                self.requests = requests
                self.requestsFetched = true
                self.getLastRequests()
            }
        } else {
            self.requestsFetched = false
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
    
    func getLastRequests() {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: NSLocalizedString("localeCode", comment: ""))
        dateFormatter.timeZone = TimeZone(identifier: NSLocalizedString("localeCode", comment: ""))
        dateFormatter.dateFormat = NSLocalizedString("dateFormat", comment: "")
        
        let currentDate = dateFormatter.date(from: dateFormatter.string(from: Date()))
        
        self.requests = self.requests.filter({
            currentDate! <  dateFormatter.date(from: dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval($0.timestamp / 1000))))!.addingTimeInterval(1800)
        })
        self.requests = self.requests.sorted(by: { $0.timestamp > $1.timestamp })
        
        NotificationCenter.default.post(Notification(name: Notification.Name(Notifications.requestsUpdated)))
    }
}
