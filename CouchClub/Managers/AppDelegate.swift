//
//  AppDelegate.swift
//  CouchClub
//
//  Created by Ruben Dias on 25/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit
import CoreData
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        performDefaultObjectsCustomization()
        
        FirebaseApp.configure()
        DataCoordinator.shared.createCurrentUserObject { (userExists) in
            FirebaseService.shared.configureListeners()
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}
    
    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}

    func performDefaultObjectsCustomization() {
        UITabBar.appearance().tintColor = UIColor.systemOrange
        UIToolbar.appearance().tintColor = UIColor.systemOrange
        UINavigationBar.appearance().tintColor = UIColor.systemOrange
    }

}
