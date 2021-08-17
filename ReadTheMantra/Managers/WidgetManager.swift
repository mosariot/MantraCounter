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
        let mantras = Array(allMantras.sorted{ $0.isFavorite && !$1.isFavorite })
        let mantrasItems = mantras.map({ WidgetModel.Item(id: $0.uuid ?? UUID(), title: $0.title ?? "", reads: $0.reads, image: $0.imageForTableView) })
        
        let widgetModel = WidgetModel(mantras: mantrasItems)
        return widgetModel
    }
    
    private func storeWidgetItem(widgetModel: WidgetModel) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(widgetModel) else { return }
        widgetItemData = data
        WidgetCenter.shared.reloadAllTimelines()
    }
}
