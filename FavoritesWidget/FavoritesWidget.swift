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
    var widgetItemData: Data = Data()
    
    func placeholder(in context: Context) -> WidgetEntry {
        let favoritesItem = WidgetModel(overallReads: 100000,
                                        favorites: [WidgetModel.Item(title: "Mantra", reads: 40000)],
                                        mantras: [WidgetModel.Item(title: "Mantra", reads: 40000)])
        return WidgetEntry(widgetModel: favoritesItem)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> ()) {
        guard let favoritesItem = try? JSONDecoder().decode(WidgetModel.self, from: widgetItemData) else {
            print("Could not decode data")
            return
        }
        let entry = WidgetEntry(widgetModel: favoritesItem)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        guard let favoritesItem = try? JSONDecoder().decode(WidgetModel.self, from: widgetItemData) else {
            print("Could not decode data")
            return
        }
        let entry = WidgetEntry(widgetModel: favoritesItem)
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

//MARK: - Small Widget View

struct SmallWidget: View {
    var entry: Provider.Entry
    
    @ViewBuilder
    var body: some View {
        let favoriteArray = Array(entry.widgetModel.favorites.prefix(3))
        let mantraArray = Array(entry.widgetModel.mantras.prefix(favoriteArray.count == 0 ? 3 : 0))
        
        ZStack {
            Color.init(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            if mantraArray.count == 0 && favoriteArray.count == 0 {
                VStack(alignment: .leading, spacing: 5) {
                    Text("ADD")
                        .font(Font(UIFont.preferredFont(for: .footnote, weight: .bold)))
                        .foregroundColor(.red)
                    Text("YOUR")
                        .font(Font(UIFont.preferredFont(for: .footnote, weight: .bold)))
                        .foregroundColor(.red)
                    Text("MANTRAS")
                        .font(Font(UIFont.preferredFont(for: .footnote, weight: .bold)))
                        .foregroundColor(.red)
                }
            }
            else {
                if favoriteArray.count > 0 {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("FAVORITES")
                            .font(Font(UIFont.preferredFont(for: .footnote, weight: .bold)))
                            .foregroundColor(.green)
                        VStack(alignment: .leading) {
                            ForEach(favoriteArray, id: \.id) { favorite in
                                Text(favorite.title)
                                    .font(Font(UIFont.preferredFont(for: .footnote, weight: .semibold)))
                                    .lineLimit(1)
                                Text(Int(favorite.reads).stringFormattedWithSpaces())
                                    .font(Font(UIFont.preferredFont(for: .footnote, weight: .bold)))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                } else {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("MANTRAS")
                            .font(Font(UIFont.preferredFont(for: .footnote, weight: .bold)))
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            ForEach(mantraArray, id: \.id) { mantra in
                                Text(mantra.title)
                                    .font(Font(UIFont.preferredFont(for: .footnote, weight: .semibold)))
                                    .lineLimit(1)
                                Text(Int(mantra.reads).stringFormattedWithSpaces())
                                    .font(Font(UIFont.preferredFont(for: .footnote, weight: .bold)))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

//MARK: - Medium Widget View

struct MediumWidget: View {
    var entry: Provider.Entry
    
    @ViewBuilder
    var body: some View {
        let favoriteArray = Array(entry.widgetModel.favorites.prefix(5))
        let mantraArray = Array(entry.widgetModel.mantras
                                    .prefix(favoriteArray.count == 0 ? 5
                                                : ((3-favoriteArray.count) >= 0 ? (3-favoriteArray.count) : 0)))
        
        ZStack {
            Color.init(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            if mantraArray.count == 0 && favoriteArray.count == 0 {
                VStack(alignment: .leading, spacing: 5) {
                    Text("ADD YOUR MANTRAS")
                        .font(Font(UIFont.preferredFont(for: .footnote, weight: .bold)))
                        .foregroundColor(.red)
                }
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    if favoriteArray.count > 0 {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("FAVORITES")
                                .font(Font(UIFont.preferredFont(for: .footnote, weight: .bold)))
                                .foregroundColor(.green)
                            VStack(spacing: 5) {
                                ForEach(favoriteArray, id: \.id) { favorite in
                                    HStack {
                                        Text(favorite.title)
                                            .font(Font(UIFont.preferredFont(for: .footnote, weight: .semibold)))
                                            .lineLimit(1)
                                        Spacer()
                                        Text(Int(favorite.reads).stringFormattedWithSpaces())
                                            .font(Font(UIFont.preferredFont(for: .footnote, weight: .bold)))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    if mantraArray.count > 0 {
                        if favoriteArray.count != 0 {
                            Divider()
                        }
                        VStack(alignment: .leading, spacing: 5) {
                            if favoriteArray.count > 0 {
                                Text("OTHER MANTRAS")
                                    .font(Font(UIFont.preferredFont(for: .footnote, weight: .bold)))
                                    .foregroundColor(.blue)
                            } else {
                                Text("MANTRAS")
                                    .font(Font(UIFont.preferredFont(for: .footnote, weight: .bold)))
                                    .foregroundColor(.blue)
                            }
                            VStack(spacing: 5) {
                                ForEach(mantraArray, id: \.id) { mantra in
                                    HStack {
                                        Text(mantra.title)
                                            .font(Font(UIFont.preferredFont(for: .footnote, weight: .semibold)))
                                            .lineLimit(1)
                                        Spacer()
                                        Text(Int(mantra.reads).stringFormattedWithSpaces())
                                            .font(Font(UIFont.preferredFont(for: .footnote, weight: .bold)))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            }
        }
    }
}

//MARK: - Large Widget View

struct LargeWidget: View {
    var entry: Provider.Entry
    
    @ViewBuilder
    var body: some View {
        let favoriteArray = Array(entry.widgetModel.favorites.prefix(10))
        let mantraArray = Array(entry.widgetModel.mantras.prefix(10-favoriteArray.count))
        
        ZStack {
            Color.init(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            if mantraArray.count == 0 && favoriteArray.count == 0 {
                VStack(alignment: .leading, spacing: 5) {
                    Text("ADD YOUR MANTRAS")
                        .font(Font(UIFont.preferredFont(for: .footnote, weight: .bold)))
                        .foregroundColor(.red)
                }
            }
            else {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("OVERALL READINGS")
                            .font(Font(UIFont.preferredFont(for: .footnote, weight: .bold)))
                            .foregroundColor(.red)
                        Spacer()
                        Text(Int(entry.widgetModel.overallReads).stringFormattedWithSpaces())
                            .font(Font(UIFont.preferredFont(for: .footnote, weight: .bold)))
                            .foregroundColor(.red)
                    }
                    if favoriteArray.count > 0 {
                        Divider()
                        VStack(alignment: .leading, spacing: 5) {
                            Text("FAVORITES")
                                .font(Font(UIFont.preferredFont(for: .footnote, weight: .bold)))
                                .foregroundColor(.green)
                            VStack(spacing: 4) {
                                ForEach(favoriteArray, id: \.id) { favorite in
                                    HStack {
                                        Text(favorite.title)
                                            .font(Font(UIFont.preferredFont(for: .footnote, weight: .semibold)))
                                            .lineLimit(1)
                                        Spacer()
                                        Text(Int(favorite.reads).stringFormattedWithSpaces())
                                            .font(Font(UIFont.preferredFont(for: .footnote, weight: .bold)))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    if mantraArray.count > 0 {
                    Divider()
                    VStack(alignment: .leading, spacing: 5) {
                        if favoriteArray.count > 0 {
                            Text("OTHER MANTRAS")
                                .font(Font(UIFont.preferredFont(for: .footnote, weight: .bold)))
                                .foregroundColor(.blue)
                        } else {
                            Text("MANTRAS")
                                .font(Font(UIFont.preferredFont(for: .footnote, weight: .bold)))
                                .foregroundColor(.blue)
                        }
                        VStack(spacing: 4) {
                            ForEach(mantraArray, id: \.id) { mantra in
                                HStack {
                                    Text(mantra.title)
                                        .font(Font(UIFont.preferredFont(for: .footnote, weight: .semibold)))
                                        .lineLimit(1)
                                    Spacer()
                                    Text(Int(mantra.reads).stringFormattedWithSpaces())
                                        .font(Font(UIFont.preferredFont(for: .footnote, weight: .bold)))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            }
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
        .configurationDisplayName("Mantra Counter")
        .description("Favorites and Your Other Mantras")
    }
}
