//
//  AppDelegate.swift
//  ReadTheMantra
//
//  Created by Александр Воробьев on 14.08.2020.
//  Copyright © 2020 Александр Воробьев. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        
        let defaults = UserDefaults.standard
        let isPreloaded = defaults.bool(forKey: "isPreloaded")
        if !isPreloaded {
            preloadData()
            defaults.set(true, forKey: "isPreloaded")
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    //MARK: - Preload Data For First Launch
    
    func preloadData() {
        let context = persistentContainer.viewContext
        for (index, data) in InitialMantra.data.enumerated() {
            let mantra = Mantra(context: context)
            mantra.position = Int32(index)
            for (key, value) in data {
                switch key {
                case .title:
                    mantra.title = value
                case .text:
                    mantra.text = value
                case .details:
                    mantra.details = value
                case .image:
                    if let image = UIImage(named: value) {
                        mantra.image = image.pngData()
                    }
                case .imageForTableView:
                    if let image = UIImage(named: value) {
                        mantra.imageForTableView = image.pngData()
                    }
                }
            }
            saveContext()
        }
    }
    
    // MARK: - Core Data Stack

    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "ReadTheMantra")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}


