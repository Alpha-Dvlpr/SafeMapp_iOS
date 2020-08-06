//
//  ToastNotification.swift
//  SafeMapp
//
//  Created by Aarón on 7/8/20.
//  Copyright © 2020 Aarón. All rights reserved.
//

import Foundation
import UIKit

open class ToastNotification: UILabel {
    
    var overlayView = UIView()
    var backView = UIView()
    var label = UILabel()
    
    class var shared: ToastNotification {
        struct Static {
            static let instance: ToastNotification = ToastNotification()
        }
        return Static.instance
    }
    
    func setup(_ view: UIView, txt_msg: String) {
        let white = UIColor (red: 1/255, green: 0/255, blue:0/255, alpha: 0.0)
        
        backView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        backView.center = view.center
        backView.backgroundColor = white
        view.addSubview(backView)
        
        overlayView.frame = CGRect(x: 0, y: 0, width: view.frame.width - 60  , height: 50)
        overlayView.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height - 100)
        overlayView.backgroundColor = UIColor.black
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 10
        overlayView.alpha = 0
        
        label.frame = CGRect(x: 0, y: 0, width: overlayView.frame.width, height: 50)
        label.numberOfLines = 0
        label.textColor = UIColor.white
        label.center = overlayView.center
        label.text = txt_msg
        label.textAlignment = .center
        label.center = CGPoint(x: overlayView.bounds.width / 2, y: overlayView.bounds.height / 2)
        overlayView.addSubview(label)
        
        view.addSubview(overlayView)
    }
    
    open func short(_ view: UIView,txt_msg:String) {
        self.setup(view, txt_msg: txt_msg)
        //Animation
        UIView.animate(withDuration: 1, animations: {
            self.overlayView.alpha = 1
        }) { (true) in
            UIView.animate(withDuration: 1, animations: {
                self.overlayView.alpha = 0
            }) { (true) in
                UIView.animate(withDuration: 1, animations: {
                    DispatchQueue.main.async(execute: {
                        self.overlayView.alpha = 0
                        self.label.removeFromSuperview()
                        self.overlayView.removeFromSuperview()
                        self.backView.removeFromSuperview()
                    })
                })
            }
        }
    }
    
    open func long(_ view: UIView,txt_msg:String) {
        self.setup(view, txt_msg: txt_msg)
        //Animation
        UIView.animate(withDuration: 2, animations: {
            self.overlayView.alpha = 1
        }) { (true) in
            UIView.animate(withDuration: 2, animations: {
                self.overlayView.alpha = 0
            }) { (true) in
                UIView.animate(withDuration: 2, animations: {
                    DispatchQueue.main.async(execute: {
                        self.overlayView.alpha = 0
                        self.label.removeFromSuperview()
                        self.overlayView.removeFromSuperview()
                        self.backView.removeFromSuperview()
                    })
                })
            }
        }
    }
}
