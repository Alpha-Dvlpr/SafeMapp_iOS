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
    var usersNear: [String] = []
    
    init() {
        self.fetchData()
    }
    
    func fetchData() {
        FirebaseManager.getRequests()
    }
}
