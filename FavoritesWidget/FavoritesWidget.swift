//
//  FavoritesWidget.swift
//  FavoritesWidget
//
//  Created by Alex Vorobiev on 19.12.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import WidgetKit
import SwiftUI

struct WidgetEntry: TimelineEntry {
    let date: Date = Date()
    let widgetModel: WidgetModel
}

//MARK: - Widget Provider

struct Provider: TimelineProvider {
    @AppStorage("widgetItem", store: UserDefaults(suiteName: "group.com.mosariot.MantraCounter"))
    private var widgetItemData: Data = Data()
    
    func placeholder(in context: Context) -> WidgetEntry {
        let placeholderMantras = Array(repeating: WidgetModel.Item(id: UUID(), title: "Mantra", reads: 40000, image: nil), count: 4)
        let widgetItem = WidgetModel(mantras: placeholderMantras)
        return WidgetEntry(widgetModel: widgetItem)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> ()) {
        guard let widgetItem = try? JSONDecoder().decode(WidgetModel.self, from: widgetItemData) else {
            print("Could not decode data")
            return
        }
        let entry = WidgetEntry(widgetModel: widgetItem)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> ()) {
        guard let widgetItem = try? JSONDecoder().decode(WidgetModel.self, from: widgetItemData) else {
            print("Could not decode data")
            return
        }
        let entry = WidgetEntry(widgetModel: widgetItem)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

//MARK: - Widget View

struct FavoritesWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidget(entry: entry)
        case .systemMedium:
            MediumWidget(entry: entry)
        case .systemLarge:
            LargeWidget(entry: entry)
        @unknown default:
            fatalError("Unknown Widget Size")
        }
    }
}

//MARK: - Widget Execution

@main
struct FavoritesWidget: Widget {
    let kind: String = "FavoritesWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FavoritesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Mantra Reader")
        .description("Favorites and Your Other Mantras")
    }
}
