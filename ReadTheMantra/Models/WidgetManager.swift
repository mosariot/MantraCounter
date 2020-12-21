//
//  WidgetFavoritesItem.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 19.12.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import SwiftUI
import WidgetKit

struct WidgetManager {
    @AppStorage("widgetItem", store: UserDefaults(suiteName: "group.com.mosariot.MantraCounter"))
    var widgetItemData: Data = Data()
    
    let widgetItem: WidgetModel
    
    func storeFavoritesItem() {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(widgetItem) else {
            print("Could not encode data")
            return
        }
        widgetItemData = data
        WidgetCenter.shared.reloadAllTimelines()
        print(String(decoding: widgetItemData, as: UTF8.self))
    }
}
