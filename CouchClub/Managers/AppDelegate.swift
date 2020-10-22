//
//  AppDelegate.swift
//  CouchClub
//
//  Created by Ruben Dias on 25/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit
import CoreData
import FirebaseCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var tabBarController: MainTabBarController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
    
        tabBarController = MainTabBarController()
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        configureDefaultAppearance()
        
        FirebaseApp.configure()
        DataCoordinator.shared.configure()
        
        PushNotifications.shared.registerForNotifications()
        
        if UserDefaultsManager.shared.isFirstLaunch {
            UserDefaultsManager.shared.isFirstLaunch = false
            
            if FirebaseService.shared.currentUserExists {
                FirebaseService.shared.signOut()
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}
    
    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}

    func configureDefaultAppearance() {
        UITabBar.appearance().tintColor = UIColor.systemOrange
        UIToolbar.appearance().tintColor = UIColor.systemOrange
        UINavigationBar.appearance().tintColor = UIColor.systemOrange
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        PushNotifications.shared.process(withUserInfo: userInfo)
        completionHandler(.newData)
    }
    
}
