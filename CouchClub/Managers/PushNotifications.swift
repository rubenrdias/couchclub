//
//  PushNotifications.swift
//  CouchClub
//
//  Created by Ruben Dias on 21/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit
import Firebase

class PushNotifications: NSObject {
    
    static var shared = PushNotifications()
    
    func registerForNotifications() {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in })
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func process(withUserInfo userInfo: [AnyHashable: Any]) {
        print("Firebase Messaging | Received new notification:\n\(userInfo)")
    }
    
}

extension PushNotifications: UNUserNotificationCenterDelegate {
    
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

extension PushNotifications: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        guard FirebaseService.shared.currentUserExists else { return }
        
        FirebaseService.shared.addDeviceFCMToken()
    }
    
}
