//
//  Notification.swift
//  meditation
//
//  Created by HuangYaqing on 2020/5/31.
//  Copyright © 2020 HuangYaqing. All rights reserved.
//

import Foundation
import UserNotifications

enum notificationId : String{
    case workDone = "com.pipasese.meditation.workDone"
    case breakOver = "com.pipasese.meditation.breakOver"
}

class Notification : NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = Notification()
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func clearNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    func sendNotification(notification: String, interval: TimeInterval,id: notificationId) {
        var options = UNAuthorizationOptions.init(arrayLiteral: .alert, .sound)
        if #available(iOS 13.0, *) {
            options.insert(.announcement)
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (flag, error) in
            guard flag else {
                return
            }
            let content = UNMutableNotificationContent.init()
            content.body = notification
            content.sound = .default
            let request = UNNotificationRequest.init(identifier: id.rawValue,
                                                     content: content,
                                                     trigger: UNTimeIntervalNotificationTrigger.init(timeInterval: interval, repeats: false))
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                if let error = error {
                    print("add notification failed:\(String(describing: error))")
                }else{
                    print("add notification \(id) ,\(notification),in \(interval) seconds")
                }
            })
        }
    }
    
    func cancel(type:notificationId){
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [type.rawValue])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        
    }
       
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
       
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.init(arrayLiteral: .alert,.sound))
    }
}
