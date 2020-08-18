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
    static let shared: MainVC = MainVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupPages()
        self.setupIntents()
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
    
    private func setupIntents() {
        let activity = NSUserActivity(activityType: "com.alpha-dvlpr.SafeMapp.sayHi")
        activity.title = NSLocalizedString("safeMappAlert", comment: "")
        activity.userInfo = ["speech" : "hi"]
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        activity.persistentIdentifier = NSUserActivityPersistentIdentifier("com.alpha-dvlpr.SafeMapp.sayHi")
        view.userActivity = activity
        activity.becomeCurrent()
    }
    
    public func sendAlertSignal() {
        let dialog = UIAlertController(title: "INFO", message: "Has lanzado una alerta", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        dialog.addAction(okAction)
        
        //TODO: fix this, view is not in the window hierarchy ???
        
        MapVC.shared.present(dialog, animated: true, completion: nil)
        ToastNotification.shared.long(MapVC.shared.view, txt_msg: "Enviando alerta...")
    }
}
