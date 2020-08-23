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
    let viewModel = MainVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addNotificationObservers()
        self.setupPages()
    }
    
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(setupBadgeValues), name: NSNotification.Name(Notifications.usersFiltered), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setupBadgeValues), name: NSNotification.Name(Notifications.requestsUpdated), object: nil)
    }
    
    @objc private func setupBadgeValues() {
        mapController.tabBarItem.badgeValue = "\(self.viewModel.nearUsers.count)"
        requestsController.tabBarItem.badgeValue = "\(self.viewModel.requests.count)"
    }
    
    private func setupPages() {
        mapController.tabBarItem.title = NSLocalizedString("home", comment: "")
        mapController.tabBarItem.image = UIImage(named: "home")
        mapController.tabBarItem.badgeColor = AppColors.redColor
        mapController.tabBarItem.badgeValue = "\(self.viewModel.nearUsers.count)"
        
        requestsController.tabBarItem.title = NSLocalizedString("requests", comment: "")
        requestsController.tabBarItem.image = UIImage(named: "requests")
        requestsController.tabBarItem.badgeColor = AppColors.redColor
        requestsController.tabBarItem.badgeValue = "\(self.viewModel.requests.count)"
        
        viewControllers = [
            mapController,
            requestsController
        ]
        
        mapController.setupVM(viewModel: self.viewModel)
        requestsController.setupVM(viewModel: self.viewModel)
    }
}
