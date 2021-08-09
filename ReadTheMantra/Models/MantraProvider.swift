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
    
    private lazy var coreDataManager = (UIApplication.shared.delegate as! AppDelegate).coreDataManager
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
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        request.fetchBatchSize = 20
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: coreDataManager.persistentContainer.viewContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: "Mantras")
        fetchedResultsController?.delegate = fetchedResultsControllerDelegate
        
        do {
            try fetchedResultsController?.performFetch()
            deleteEmptyMantrasIfNeeded()
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    func addPreloadedMantras(with selectedMantrasTitles: [String]) {
        let selectedMantras = sortedInitialMantraData.filter { 
            guard let title = $0[.title] else { return false }
            return selectedMantrasTitles.contains(title)
        }
        selectedMantras.forEach { (selectedMantra) in
            let mantra = Mantra(context: coreDataManager.persistentContainer.viewContext)
            mantra.uuid = UUID()
            mantra.title = selectedMantra[.title]
            mantra.text = selectedMantra[.text]
            mantra.details = selectedMantra[.details]
            mantra.image = UIImage(named: selectedMantra[.image] ?? Constants.defaultImage)?.pngData()
            mantra.imageForTableView = UIImage(named: selectedMantra[.image] ?? Constants.defaultImage)?
                .resize(to: CGSize(width: Constants.rowHeight,
                                   height: Constants.rowHeight)).pngData()
        }
    }
    
    func updateValues(for mantra: Mantra, with value: Int32, adjustingType: AdjustingType) {
        switch adjustingType {
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
    
    func buildOrUpdateMantra(mantra: Mantra, title: String, text: String, details: String, imageData: Data?, imageForTableViewData: Data?) {
        mantra.title = title
        mantra.text = text
        mantra.details = details
        mantra.image = imageData ?? nil
        mantra.imageForTableView = imageForTableViewData ?? nil
    }
    
    func saveMantras() {
        coreDataManager.saveContext()
    }
    
    func makeNewMantra() -> Mantra {
        Mantra(context: coreDataManager.persistentContainer.viewContext)
    }
    
    func deleteMantra(_ mantra: Mantra) {
        coreDataManager.deleteMantra(mantra)
    }
    
    private func deleteEmptyMantrasIfNeeded() {
        fetchedResultsController?.fetchedObjects?
            .filter{ $0.title == "" }
            .forEach { (mantra) in
                coreDataManager.deleteMantra(mantra)
            }
    }
}
