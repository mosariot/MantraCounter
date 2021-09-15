//
//  MantraWidget.swift
//  FavoritesWidgetExtension
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
        let placeholderMantras = Array(repeating: WidgetModel.Item(id: UUID(), title: "Mantra", reads: 40000, image: nil), count: 6)
        let widgetItem = WidgetModel(mantras: placeholderMantras)
        return WidgetEntry(widgetModel: widgetItem)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> ()) {
        guard let widgetItem = try? JSONDecoder().decode(WidgetModel.self, from: widgetItemData) else { return }
        let entry = WidgetEntry(widgetModel: widgetItem)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> ()) {
        guard let widgetItem = try? JSONDecoder().decode(WidgetModel.self, from: widgetItemData) else { return }
        let entry = WidgetEntry(widgetModel: widgetItem)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

//MARK: - Widget View

struct MantraWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidget(widgetModel: entry.widgetModel)
        case .systemMedium:
            MediumWidget(widgetModel: entry.widgetModel)
        case .systemLarge:
            LargeWidget(widgetModel: entry.widgetModel)
        case .systemExtraLarge:
            fatalError("Extra Large size not implemented")
        @unknown default:
            fatalError("Unknown Widget Size")
        }
    }
}

//MARK: - Widget Execution

@main
struct MantraWidget: Widget {
    let kind: String = "MantraWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MantraWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Mantra Reader")
        .description("Favorites and Your Other Mantras")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
