//
//  MantraProvider.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 08.02.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit
import CoreData

class MantraProvider {
    
    private lazy var context = (UIApplication.shared.delegate as! AppDelegate).coreDataManager.persistentContainer.viewContext
    private weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?
    private(set) var fetchedResultsController: NSFetchedResultsController<Mantra>?
    private lazy var sortedInitialMantraData = InitialMantra.sortedData()
    
    var fetchedMantras: [Mantra] {
        fetchedResultsController?.fetchedObjects?.filter{ $0.title != "" } ?? []
    }
    
    init(fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate? = nil) {
        self.fetchedResultsControllerDelegate = fetchedResultsControllerDelegate
    }
    
    func loadMantras() {
        let request: NSFetchRequest<Mantra> = Mantra.fetchRequest()
        request.sortDescriptors = UserDefaults.standard.bool(forKey: "isAlphabeticalSorting") ?
            [NSSortDescriptor(key: "title", ascending: true)] :
            [NSSortDescriptor(key: "reads", ascending: false), NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: context,
                                                              sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = fetchedResultsControllerDelegate
        
        do {
            try fetchedResultsController?.performFetch()
            deleteEmptyMantrasIfNeeded()
        } catch {
            print("Error fetching data \(error)")
        }
    }
    
    func addPreloadedMantra(with selectedMantraNumber: Int) {
        let preloadedMantra = sortedInitialMantraData[selectedMantraNumber]
        let mantra = Mantra(context: context)
        mantra.uuid = UUID()
        mantra.title = preloadedMantra[.title]
        mantra.text = preloadedMantra[.text]
        mantra.details = preloadedMantra[.details]
        mantra.image = UIImage(named: preloadedMantra[.image] ?? Constants.defaultImage)?.pngData()
        mantra.imageForTableView = UIImage(named: preloadedMantra[.image] ?? Constants.defaultImage)?
            .resize(to: CGSize(width: Constants.rowHeight,
                               height: Constants.rowHeight)).pngData()
    }
    
    func updateValues(for mantra: Mantra, with value: Int32, updatingType: UpdatingType) {
        switch updatingType {
        case .goal:
            mantra.readsGoal = value
        case .reads:
            mantra.reads += value
        case .rounds:
            mantra.reads += value * 108
        case .properValue:
            mantra.reads = value
        }
    }
    
    func processMantra(mantra: Mantra, title: String, text: String, details: String, imageData: Data?, imageForTableViewData: Data?) {
        mantra.title = title
        mantra.text = text
        mantra.details = details
        mantra.image = imageData ?? nil
        mantra.imageForTableView = imageForTableViewData ?? nil
    }
    
    func deleteMantra(_ mantra: Mantra) {
        context.delete(mantra)
    }
    
    private func deleteEmptyMantrasIfNeeded() {
        fetchedResultsController?.fetchedObjects?
            .filter{ $0.title == "" }
            .forEach { (mantra) in
                context.delete(mantra)
            }
    }
}
