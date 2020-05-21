//
//  NotificationsService.swift
//  CouchClub
//
//  Created by Ruben Dias on 21/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationService {
    
    static var shared = NotificationService()
    
    private init() {}
    
    func configure(_ application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        
        application.registerForRemoteNotifications()
    }
    
}

extension NotificationService {
    
}
