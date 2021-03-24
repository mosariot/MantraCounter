//
//  LargeWidgetView.swift
//  FavoritesWidgetExtension
//
//  Created by Alex Vorobiev on 21.03.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import WidgetKit
import SwiftUI

struct LargeWidget: View {
    var entry: Provider.Entry
    
    @ViewBuilder
    var body: some View {
        let favoriteArray = Array(entry.widgetModel.favorites.prefix(8))
        let mantraArray = Array(entry.widgetModel.mantras
                                    .prefix(favoriteArray.count == 0 ? 8
                                                                    : ((7-favoriteArray.count) >= 0 ? (7-favoriteArray.count) : 0)))
        
        ZStack {
            Color.init(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            if mantraArray.count == 0 && favoriteArray.count == 0 {
                Image("DefaultImage")
            } else {
                VStack(alignment: .leading, spacing: 9) {
                    HStack {
                        Text("OVERALL READINGS")
                            .font(Font(UIFont.preferredFont(for: .footnote, weight: .semibold)))
                            .foregroundColor(.red)
                        Spacer()
                        Text(Int(entry.widgetModel.overallReads).stringFormattedWithSpaces())
                            .font(Font(UIFont.preferredFont(for: .footnote, weight: .semibold)))
                            .foregroundColor(.red)
                    }
                    Divider()
                    if favoriteArray.count > 0 {
                        VStack(alignment: .leading, spacing: 9) {
                            Text("FAVORITES")
                                .font(Font(UIFont.preferredFont(for: .footnote, weight: .semibold)))
                                .foregroundColor(.green)
                            VStack(spacing: 5) {
                                ForEach(favoriteArray, id: \.self) { favorite in
                                    Link(destination: URL(string: "\(favorite.id)")!) {
                                        VStack {
                                            HStack {
                                                Text(favorite.title)
                                                    .font(Font(UIFont.preferredFont(for: .footnote, weight: .semibold)))
                                                    .lineLimit(1)
                                                Spacer()
                                                Text(Int(favorite.reads).stringFormattedWithSpaces())
                                                    .font(Font(UIFont.preferredFont(for: .footnote, weight: .semibold)))
                                                    .foregroundColor(.secondary)
                                            }
                                            Divider()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if mantraArray.count > 0 {
                        VStack(alignment: .leading, spacing: 9) {
                            if favoriteArray.count > 0 {
                                Text("OTHER MANTRAS")
                                    .font(Font(UIFont.preferredFont(for: .footnote, weight: .semibold)))
                                    .foregroundColor(.blue)
                            } else {
                                Text("MANTRAS")
                                    .font(Font(UIFont.preferredFont(for: .footnote, weight: .semibold)))
                                    .foregroundColor(.blue)
                            }
                            VStack(spacing: 5) {
                                ForEach(mantraArray, id: \.self) { mantra in
                                    Link(destination: URL(string: "\(mantra.id)")!) {
                                        VStack {
                                            HStack {
                                                Text(mantra.title)
                                                    .font(Font(UIFont.preferredFont(for: .footnote, weight: .semibold)))
                                                    .lineLimit(1)
                                                Spacer()
                                                Text(Int(mantra.reads).stringFormattedWithSpaces())
                                                    .font(Font(UIFont.preferredFont(for: .footnote, weight: .semibold)))
                                                    .foregroundColor(.secondary)
                                            }
                                            Divider()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
            }
        }
    }
}
