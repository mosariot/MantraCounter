//
//  DataStore.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 27.10.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import Foundation

final class DataStore {
    
    private var mantraDataManager: DataManager
    private let defaults = UserDefaults.standard
    private var continuation: AsyncStream<Void>.Continuation?
    var isAlphabeticalSorting: Bool {
        get {
            defaults.bool(forKey: "isAlphabeticalSorting")
        }
        set {
            defaults.set(newValue, forKey: "isAlphabeticalSorting")
            syncDisplayedMantrasWithOverallMantras()
            sortingDidChanged()
        }
    }
    
    var overallMantras: [Mantra] {
        isAlphabeticalSorting ?
        mantraDataManager.fetchedMantras.sorted {
            guard let title1 = $0.title, let title2 = $1.title else { return false }
            return title1.localizedStandardCompare(title2) == .orderedAscending } :
        mantraDataManager.fetchedMantras.sorted { $0.reads > $1.reads }
    }
    
    lazy var displayedMantras = overallMantras
    
    var favoritesSectionMantras: [Mantra] {
        displayedMantras.filter { $0.isFavorite }
    }
    var mainSectionMantras: [Mantra] {
        displayedMantras.filter { !$0.isFavorite }
    }
    
    init(dataManager: DataManager) {
        self.mantraDataManager = dataManager
    }
    
    func mantraFor(_ mantraID: ObjectIdentifier) -> Mantra? {
        displayedMantras.first(where: {$0.id == mantraID})
    }
    
    func mantraFor(_ uuid: UUID) -> Mantra? {
        displayedMantras.filter({ $0.uuid == uuid }).first
    }
    
    func favoritesSectionMantrasIDs() -> [ObjectIdentifier] {
        favoritesSectionMantras.map { $0.id }
    }
    
    func mainSectionMantrasIDs() -> [ObjectIdentifier] {
        mainSectionMantras.map { $0.id }
    }
    
    func syncDisplayedMantrasWithOverallMantras() {
        displayedMantras = overallMantras
    }
    
    func filterDisplayedMantrasWith(_ text: String) {
        displayedMantras = overallMantras.filter {
            if let title = $0.title {
                return title.localizedCaseInsensitiveContains(text)
            } else {
                return false
            }
        }
    }
    
    func listenForSortingChange() async -> AsyncStream<Void> {
        AsyncStream<Void> { continuation in self.continuation = continuation }
    }
    
    private func sortingDidChanged() {
        continuation?.yield()
    }
    
    deinit {
        continuation?.finish()
    }
}
