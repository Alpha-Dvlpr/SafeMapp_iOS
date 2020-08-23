//
//  MainVM.swift
//  SafeMapp
//
//  Created by Aarón on 22/8/20.
//  Copyright © 2020 Aarón. All rights reserved.
//

import Foundation

class MainVM {
    var requests: [Request] = []
    var usersNear: [User] = []
    
    init() {
        self.addNotificationObservers()
        self.fetchData()
    }
    
    private func addNotificationObservers() {
        
    }
    
    func fetchData() {
        FirebaseManager.getRequests()
        FirebaseManager.getUsers()
    }
}
