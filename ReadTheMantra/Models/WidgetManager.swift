//
//  WidgetManager.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 19.12.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import SwiftUI
import CoreData
import WidgetKit

struct WidgetManager {
    @AppStorage("widgetItem", store: UserDefaults(suiteName: "group.com.mosariot.MantraCounter"))
    private var widgetItemData: Data = Data()
    
    func updateWidgetData(for allMantras: [Mantra]) {
        let widgetModel = getWidgetModel(for: allMantras)
        storeWidgetItem(widgetModel: widgetModel)
    }
    
    private func getWidgetModel(for allMantras: [Mantra]) -> WidgetModel {
        let overallReads = allMantras.map({ $0.reads }).reduce(0, +)
        
        let mantras = Array(allMantras.filter{ !$0.isFavorite })
        let favoritesMantras = Array(allMantras.filter{ $0.isFavorite })
        
        let mantrasItems = mantras.map({ WidgetModel.Item(title: $0.title ?? "", reads: $0.reads) })
        let favoritesMantrasItems = favoritesMantras.map({ WidgetModel.Item(title: $0.title ?? "", reads: $0.reads) })
        
        let widgetModel = WidgetModel(overallReads: overallReads, favorites: favoritesMantrasItems, mantras: mantrasItems)
        return widgetModel
    }
    
    private func storeWidgetItem(widgetModel: WidgetModel) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(widgetModel) else { return }
        widgetItemData = data
        WidgetCenter.shared.reloadAllTimelines()
    }
}
