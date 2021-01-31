//
//  CoreDataManager.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 01.01.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit
import CoreData

final class CoreDataManager {
    
    init() {
        registerDefaults()
        handleFirstLaunch()
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentCloudKitContainer(name: "ReadTheMantra")
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }
        
        // Enabale self-cleaining for SQL database
        description.setOption(true as NSNumber, forKey: NSSQLiteManualVacuumOption)
        // Enable history tracking and remote notifications
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores(completionHandler: { (_, error) in
            guard let error = error as NSError? else { return }
            fatalError("Failed to load persistent stores: \(error)")
        })
        
        // Pin the viewContext to the current generation token and set it to keep itself up to date with local changes
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        do {
            try container.viewContext.setQueryGenerationFrom(.current)
        } catch {
            fatalError("Failed to pin viewContext to the current generation: \(error)")
        }
        
        return container
    }()
    
    func saveContext() {
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
    
    //MARK: - Register Defaults
    
    func registerDefaults() {
        let dictionary = ["isFirstLaunch": true,
                          "isOnboarding": true,
                          "isInitalDataLoading": true,
                          "isFirstSearchOnTheInternet": true]
        UserDefaults.standard.register(defaults: dictionary)
    }
    
}
    
//MARK: - Preload Data For First Launch

extension CoreDataManager {
    
    func handleFirstLaunch() {
        let networkMonitor = NetworkMonitor()
        let isFirstLaunch = UserDefaults.standard.bool(forKey: "isFirstLaunch")
        if isFirstLaunch {
            networkMonitor.startMonitoring()
            DispatchQueue.main.async {
                if !(networkMonitor.isReachable) {
                    self.preloadData()
                } else {
                    self.checkForiCloudRecords()
                }
                UserDefaults.standard.set(false, forKey: "isFirstLaunch")
                networkMonitor.stopMonitoring()
            }
        }
    }
    
    func checkForiCloudRecords() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "CD_Mantra", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        var recordsCount = 0
        
        operation.recordFetchedBlock = { _ in
            recordsCount += 1
        }
        
        operation.queryCompletionBlock = { (_, error) in
            DispatchQueue.main.async {
                if error == nil {
                    // no records in iCloud
                    if recordsCount == 0 {
                        self.preloadData()
                    } else {
                        // loading records from iCloud
                    }
                } else {
                    // for example there is no iCloud Account
                    self.preloadData()
                }
            }
        }
        CKContainer.default().privateCloudDatabase.add(operation)
    }
    
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
                        mantra.imageForTableView = image.resize(to: CGSize(width: Constants.rowHeight, height: Constants.rowHeight)).pngData()
                    }
                }
            }
            saveContext()
        }
    }
}
