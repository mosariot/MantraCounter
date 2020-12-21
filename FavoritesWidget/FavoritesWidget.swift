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
    let favoritesItem: WidgetModel
}

//MARK: - Widget Provider

struct Provider: TimelineProvider {
    @AppStorage("widgetItem", store: UserDefaults(suiteName: "group.com.mosariot.MantraCounter"))
    var widgetItemData: Data = Data()
    
    func placeholder(in context: Context) -> WidgetEntry {
        let favoritesItem = WidgetModel(overallReads: 80000, favorites: [WidgetModel.Item(title: "Mantra", reads: 40000)], mantras: [WidgetModel.Item(title: "Mantra", reads: 40000)])
        return WidgetEntry(favoritesItem: favoritesItem)
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> ()) {
        guard let favoritesItem = try? JSONDecoder().decode(WidgetModel.self, from: widgetItemData) else {
            print("Could not decode data")
            return
        }
        let entry = WidgetEntry(favoritesItem: favoritesItem)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        guard let favoritesItem = try? JSONDecoder().decode(WidgetModel.self, from: widgetItemData) else {
            print("Could not decode data")
            return
        }
        let entry = WidgetEntry(favoritesItem: favoritesItem)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

//MARK: - Widget Views

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
        let favoriteArray = Array(entry.favoritesItem.favorites.prefix(3))
        let mantraArray = Array(entry.favoritesItem.mantras
                                    .prefix(favoriteArray.count == 0 ? 3 : 0))
        
        VStack(alignment: .leading) {
            if favoriteArray.count > 0 {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("Favorites", comment: "Widget Subtitle"))
                        .font(Font(UIFont.preferredFont(for: .title3, weight: .bold)))
                        .foregroundColor(.green)
                    VStack(alignment: .leading) {
                        ForEach(favoriteArray, id: \.id) { favorite in
                            Text(favorite.title)
                                .font(.subheadline)
                            Text(String(favorite.reads))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } else {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("Mantras", comment: "Widget Subtitle"))
                        .font(Font(UIFont.preferredFont(for: .title3, weight: .bold)))
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        ForEach(mantraArray, id: \.id) { mantra in
                            Text(mantra.title)
                                .font(.subheadline)
                            Text(String(mantra.reads))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
    }
}

//MARK: - Medium Widget View

struct MediumWidget: View {
    var entry: Provider.Entry
    
    @ViewBuilder
    var body: some View {
        let favoriteArray = Array(entry.favoritesItem.favorites.prefix(4))
        let mantraArray = Array(entry.favoritesItem.mantras
                                    .prefix(favoriteArray.count == 0 ? 4
                                                : ((2-favoriteArray.count) >= 0 ? (2-favoriteArray.count) : 0)))
        
        VStack(alignment: .leading, spacing: 10) {
            if favoriteArray.count > 0 {
                VStack(alignment: .leading, spacing: 5) {
                    Text(NSLocalizedString("Favorites", comment: "Widget Subtitle"))
                        .font(Font(UIFont.preferredFont(for: .title3, weight: .bold)))
                        .foregroundColor(.green)
                    VStack(spacing: 5) {
                        ForEach(favoriteArray, id: \.id) { favorite in
                            HStack {
                                Text(favorite.title)
                                    .font(.callout)
                                Spacer()
                                Text(String(favorite.reads))
                                    .font(.callout)
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
                    Text(NSLocalizedString("Mantras", comment: "Widget Subtitle"))
                        .font(Font(UIFont.preferredFont(for: .title3, weight: .bold)))
                        .foregroundColor(.blue)
                    VStack(spacing: 5) {
                        ForEach(mantraArray, id: \.id) { mantra in
                            HStack {
                                Text(mantra.title)
                                    .font(.callout)
                                Spacer()
                                Text(String(mantra.reads))
                                    .font(.callout)
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

//MARK: - Large Widget View

struct LargeWidget: View {
    var entry: Provider.Entry
    
    @ViewBuilder
    var body: some View {
        let favoriteArray = Array(entry.favoritesItem.favorites.prefix(8))
        let mantraArray = Array(entry.favoritesItem.mantras
                                    .prefix(favoriteArray.count == 0 ? 8
                                                : ((7-favoriteArray.count) >= 0 ? (7-favoriteArray.count) : 0)))
        
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(NSLocalizedString("Overall readings", comment: "Widget Subtitle"))
                    .font(Font(UIFont.preferredFont(for: .title3, weight: .bold)))
                    .foregroundColor(.red)
                Spacer()
                Text(String(entry.favoritesItem.overallReads))
                    .font(Font(UIFont.preferredFont(for: .title3, weight: .bold)))
                    .foregroundColor(.secondary)
            }
            if favoriteArray.count > 0 {
                Divider()
                VStack(alignment: .leading, spacing: 5) {
                    Text(NSLocalizedString("Favorites", comment: "Widget Subtitle"))
                        .font(Font(UIFont.preferredFont(for: .title3, weight: .bold)))
                        .foregroundColor(.green)
                    VStack(spacing: 5) {
                        ForEach(favoriteArray, id: \.id) { favorite in
                            HStack {
                                Text(favorite.title)
                                    .font(.callout)
                                Spacer()
                                Text(String(favorite.reads))
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            if mantraArray.count > 0 {
                Divider()
                VStack(alignment: .leading, spacing: 5) {
                    Text(NSLocalizedString("Mantras", comment: "Widget Subtitle"))
                        .font(Font(UIFont.preferredFont(for: .title3, weight: .bold)))
                        .foregroundColor(.blue)
                    VStack(spacing: 5) {
                        ForEach(mantraArray, id: \.id) { mantra in
                            HStack {
                                Text(mantra.title)
                                    .font(.callout)
                                Spacer()
                                Text(String(mantra.reads))
                                    .font(.callout)
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

//MARK: - Widget Execution

@main
struct FavoritesWidget: Widget {
    let kind: String = "FavoritesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FavoritesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(NSLocalizedString("Mantra Counter", comment: "Widget Title"))
        .description(NSLocalizedString("Favorites and Your Other Mantras", comment: "Widget Description"))
    }
}
