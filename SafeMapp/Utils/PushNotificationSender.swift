//
//  PushNotificationSender.swift
//  SafeMapp
//
//  Created by Aarón on 27/8/20.
//  Copyright © 2020 Aarón. All rights reserved.
//

import Foundation

class PushNotificationSender {
    func sendPushNotification(to token: String, title: String, body: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = [
            "to": token,
            "notification": [
                "title": title,
                "body": body,
                "data": [ "user": "test_id" ]
            ]
        ]
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAy41zmaM:APA91bFMO9jaHM41O6Nbu-uCzjzzl54cFY6ikfy1rvCwYvJSMAyt37mujg6Il8zoQYyROsAPOQSlbTJyBN0QX9IzNZao96DxaOmYTNfh3pHHad16KrNAL_SDQxKYSW1pIVYTvYIytVOn", forHTTPHeaderField: "Authorization")

        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError { print(err.debugDescription) }
        }
        
        task.resume()
    }
}
