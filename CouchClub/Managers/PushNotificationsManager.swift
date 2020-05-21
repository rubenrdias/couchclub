//
//  PushNotificationsManager.swift
//  CouchClub
//
//  Created by Ruben Dias on 21/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit
import Firebase

class PushNotificationsManager: NSObject {
    
    static var shared = PushNotificationsManager()
    
    func registerForPushNotifications() {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in })
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func processNotification(_ userInfo: [AnyHashable: Any]) {
        print("Firebase Messaging | Received new notification:\n\(userInfo)")
    }
    
}

extension PushNotificationsManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Application | Will present notification with UserInfo: \(userInfo)")
        completionHandler([.alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("Application | Received response for notification with UserInfo: \(userInfo)")
        completionHandler()
    }
    
}

extension PushNotificationsManager: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        FirebaseService.shared.addDeviceFCMToken()
    }
    
}
