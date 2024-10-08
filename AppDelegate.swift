//
//  AppDelegate.swift
//  ScholarSync-Adam
//
//  Created by Adam on 8/19/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupRoot()
        return true
    }
    
    func setupRoot() {
        if window == nil {
            window = UIWindow(frame: UIScreen.main.bounds)
        }
        let navVC = UINavigationController(rootViewController: MainVC())
        window?.rootViewController = navVC
        window?.makeKeyAndVisible()
        
    }
    // MARK: UISceneSession Lifecycle


}

