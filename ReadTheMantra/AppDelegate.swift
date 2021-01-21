//
//  AppDelegate.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 14.08.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let coreDataManager = CoreDataManager.shared
    let networkMonitor = NetworkMonitor.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        
        // preload data for first launch
        let defaults = UserDefaults.standard
        let hasLaunched = defaults.bool(forKey: "hasLaunched")
        if !hasLaunched {
            networkMonitor.startMonitoring()
            DispatchQueue.main.async {
                if !(self.networkMonitor.isReachable) {
                    self.coreDataManager.preloadData()
                } else {
                    self.coreDataManager.checkForiCloudRecords()
                }
                defaults.set(true, forKey: "hasLaunched")
                self.networkMonitor.stopMonitoring()
            }
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}


