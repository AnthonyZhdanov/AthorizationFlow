//
//  AppDelegate.swift
//  Example
//
//  Created by Anton Zhdanov on 19.02.18.
//  Copyright © 2018 Anton Zhdanov. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        setupBars()
        
        // Status Bar White Color
//        application.statusBarStyle = .lightContent
        
        // Enable IQKeyboardManager
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.toolbarTintColor = UIColor.red
        IQKeyboardManager.shared.toolbarBarTintColor = UIColor.black
        
        NotificationCenter.default.addObserver(self, selector: #selector(logUserOut), name: NSNotification.Name(rawValue: "403expired"), object: nil)
        
        return true
    }
    
    private func setupBars() {
        // Navigation Bar Appearance
        let navigationBarAppearance = UINavigationBar.appearance()
        
        navigationBarAppearance.isTranslucent = true
        navigationBarAppearance.tintColor = UIColor.white
        navigationBarAppearance.barTintColor = UIColor.white
        navigationBarAppearance.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationBarAppearance.shadowImage = UIImage()
        
        // Change Navigation Item Title Color
        navigationBarAppearance.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        // Global Tint Color
        self.window?.tintColor = UIColor.red
    }
    
    @objc private func logUserOut() {
        SessionManager.shared.logOutUser {
            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Welcome"), object: nil)
                }
            })
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}
