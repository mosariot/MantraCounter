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
        var overallReads: Int32 = 0
        var favoritesMantrasItems: [WidgetModel.Item] = []
        var mantrasItems: [WidgetModel.Item] = []
        
        for mantra in overallMantraArray {
            overallReads += mantra.reads
        }
        
        let favoritesMantras = Array(overallMantraArray
                                        .filter{ $0.isFavorite }
                                        .sorted{ $0.positionFavorite < $1.positionFavorite })
        let mantras = Array(overallMantraArray
                                .sorted{ $0.position < $1.position })
        
        for favoriteItem in favoritesMantras {
            if let title = favoriteItem.title {
                favoritesMantrasItems.append(WidgetModel.Item(title: title, reads: favoriteItem.reads))
            }
        }
        
        for mantraItem in mantras {
            if let title = mantraItem.title {
                mantrasItems.append(WidgetModel.Item(title: title, reads: mantraItem.reads))
            }
        }
        
        let widgetModel = WidgetModel(overallReads: overallReads, favorites: favoritesMantrasItems, mantras: mantrasItems)
        return widgetModel
    }
    
    private func storeWidgetItem(widgetModel: WidgetModel) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(widgetModel) else {
            print("Could not encode data")
            return
        }
        widgetItemData = data
        WidgetCenter.shared.reloadAllTimelines()
    }
}
