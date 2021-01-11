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
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ReadTheMantra")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
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
                        mantra.imageForTableView = image.resize(to: CGSize(width: Constants.rowHeight, height: Constants.rowHeight))?.pngData()
                    }
                }
            }
            saveContext()
        }
    }
}
