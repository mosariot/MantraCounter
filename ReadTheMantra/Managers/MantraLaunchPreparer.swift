//
//  MantraLaunchPreparer.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 17.08.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit
import CloudKit

final class MantraLaunchPreparer: LaunchPreparer {
    
    private var dataBaseManager: DataBaseManager
    
    init(dataBaseManager: DataBaseManager) {
        self.dataBaseManager = dataBaseManager
    }
    
    //MARK: - Register Defaults
    
    func registerDefaults() {
        let dictionary = ["isFirstLaunch": true,
                          "isOnboarding": true,
                          "isInitalDataLoading": true,
                          "isFirstSearchOnTheInternet": true,
                          "isFirstSwitchDisplayMode": true,
                          "isAlphabeticalSorting": true,
                          "isPreloadedMantrasDueToNoInternetConnection": false]
        UserDefaults.standard.register(defaults: dictionary)
    }
    
    //MARK: - Preload Data For First Launch
    
    func checkForFirstLaunch() {
        let isFirstLaunch = UserDefaults.standard.bool(forKey: "isFirstLaunch")
        if isFirstLaunch {
            let networkMonitor = NetworkMonitor()
            networkMonitor.startMonitoring()
            DispatchQueue.main.async {
                if !(networkMonitor.isReachable) {
                    self.dataBaseManager.preloadData()
                    UserDefaults.standard.set(true, forKey: "isPreloadedMantrasDueToNoInternetConnection")
                    UserDefaults.standard.set(false, forKey: "isInitalDataLoading")
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
        
        operation.queryCompletionBlock = { _, error in
            DispatchQueue.main.async {
                if error == nil {
                    if recordsCount == 0 {
                        // no records in iCloud
                        self.dataBaseManager.preloadData()
                    } else {
                        // automatically handle loading records from iCloud
                    }
                } else {
                    // for example user is not logged-in iCloud
                    self.dataBaseManager.preloadData()
                }
            }
        }
        CKContainer.default().privateCloudDatabase.add(operation)
    }
}
