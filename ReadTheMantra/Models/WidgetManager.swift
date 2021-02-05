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
    var widgetItemData: Data = Data()
    
    private var overallMantraArray: [Mantra] {
        (UIApplication.shared.delegate as! AppDelegate).coreDataManager.overallMantraArray
    }
    
    func updateWidgetData() {
        let widgetModel = getWidgetModel()
        storeWidgetItem(widgetModel: widgetModel)
    }
    
    private func getWidgetModel() -> WidgetModel {
        let allMantras = overallMantraArray
        let overallReads = allMantras.map({ $0.reads }).reduce(0, +)
        
        let mantras = Array(allMantras.sorted{ $0.position < $1.position })
        let favoritesMantras = Array(allMantras
                                        .filter{ $0.isFavorite }
                                        .sorted{ $0.positionFavorite < $1.positionFavorite })
        
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
