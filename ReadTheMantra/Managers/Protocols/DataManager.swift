//
//  DataManager.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 17.08.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import Foundation

protocol DataManager {
    
    var fetchedMantras: [Mantra] { get }
    func loadMantras()
    func saveMantras()
    func addPreloadedMantras(with selectedMantrasTitles: [String])
    func updateMantraValues(_ mantra: Mantra, with value: Int32, and adjustingType: AdjustingType)
    func buildOrUpdateMantra(_ mantra: Mantra, title: String, text: String, details: String, imageData: Data?, imageForTableViewData: Data?)
    func makeNewMantra() -> Mantra
    func deleteMantra(_ mantra: Mantra)
    func preloadData()
}
