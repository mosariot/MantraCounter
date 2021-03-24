//
//  SmallWidgetView.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 21.03.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import WidgetKit
import SwiftUI

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
                Image("DefaultImage")
                    .resizable()
                    .frame(width: 100, height: 100, alignment: .center)
            } else {
                if favoriteArray.count > 0 {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("FAVORITES")
                            .font(Font(UIFont.preferredFont(for: .footnote, weight: .bold)))
                            .foregroundColor(.green)
                        VStack(alignment: .leading) {
                            ForEach(favoriteArray, id: \.self) { favorite in
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
                            ForEach(mantraArray, id: \.self) { mantra in
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
