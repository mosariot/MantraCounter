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
    
    static let shared = CoreDataManager()
    
    var overallMantraArray: [Mantra] {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<Mantra> = Mantra.fetchRequest()
        request.sortDescriptors = UserDefaults.standard.bool(forKey: "isAlphabeticalSorting") ?
            [NSSortDescriptor(key: "title", ascending: true)] : [NSSortDescriptor(key: "reads", ascending: false)]
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
            return []
        }
    }
    
    private init() { }
    
    private(set) lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentCloudKitContainer(name: "ReadTheMantra")
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }
        
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
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror)")
        }
    }
}
    
    //MARK: - Register Defaults
    
extension CoreDataManager {
    
    func registerDefaults() {
        let dictionary = ["isFirstLaunch": true,
                          "isOnboarding": true,
                          "isInitalDataLoading": true,
                          "isFirstSearchOnTheInternet": true,
                          "isAlphabeticalSorting": true]
        UserDefaults.standard.register(defaults: dictionary)
    }
}

//MARK: - Preload Data For First Launch

extension CoreDataManager {
    
    func checkForFirstLaunch() {
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
    
    private func checkForiCloudRecords() {
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
                    if recordsCount == 0 {
                        // no records in iCloud
                        self.preloadData()
                    } else {
                        // automatically handle loading records from iCloud
                    }
                } else {
                    // for example user is not logged-in iCloud
                    self.preloadData()
                }
            }
        }
        CKContainer.default().privateCloudDatabase.add(operation)
    }
    
    private func preloadData() {
        let context = persistentContainer.viewContext
        InitialMantra.data.forEach { (data) in
            let mantra = Mantra(context: context)
            mantra.uuid = UUID()
            data.forEach { (key, value) in
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
        }
        saveContext()
    }
}
