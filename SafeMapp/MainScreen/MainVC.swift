//
//  MainVC.swift
//  SafeMapp
//
//  Created by Aarón on 13/8/20.
//  Copyright © 2020 Aarón. All rights reserved.
//

import UIKit

class MainVC: UITabBarController {
    let mapController = MapVC()
    let requestsController = RequestsVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupPages()
    }
    
    private func setupPages() {
        mapController.tabBarItem.title = NSLocalizedString("home", comment: "")
        mapController.tabBarItem.image = UIImage(named: "home")
        
        requestsController.tabBarItem.title = NSLocalizedString("requests", comment: "")
        requestsController.tabBarItem.image = UIImage(named: "requests")
        requestsController.tabBarItem.badgeColor = UIColor.red
        
        viewControllers = [
            mapController,
            requestsController
        ]
    }
}
