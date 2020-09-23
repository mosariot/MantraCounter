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
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    //MARK: - Preload Data Stack
    
    func preloadData() {
        removeData()
        let context = persistentContainer.viewContext
        
        for (index, data) in InitialMantra.data.enumerated() {
            let mantra = Mantra(context: context)
            mantra.position = Int32(index)
            mantra.isFavorite = false
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
    
    func removeData() {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<Mantra> = Mantra.fetchRequest()
        do {
            let mantraArray = try context.fetch(request)
            for mantra in mantraArray {
                context.delete(mantra)
            }
        } catch {
            print("Error fetching data from context \(error)")
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

    // MARK: - Core Data Saving support

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


