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
    
    var widgetModel: WidgetModel
    
    var body: some View {
        let mantraArray = widgetModel.mantras.prefix(6)
        
        ZStack {
            Color.init(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            if mantraArray.count == 0 {
                Image("DefaultImage")
            } else {
                VStack {
                    ForEach(mantraArray, id: \.self) { mantra in
                        Link(destination: URL(string: "\(mantra.id)")!) {
                            VStack() {
                                HStack {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(mantra.title)
                                            .font(Font(UIFont.preferredFont(for: .footnote, weight: .semibold)))
                                            .lineLimit(1)
                                        HStack(spacing: 0) {
                                            Text("Current readings: ")
                                                .font(Font(UIFont.preferredFont(for: .footnote, weight: .semibold)))
                                                .foregroundColor(.secondary)
                                            Text(Int(mantra.reads).formattedNumber())
                                                .font(Font(UIFont.preferredFont(for: .footnote, weight: .semibold)))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                    Image(uiImage: ((mantra.image != nil) ?
                                                        UIImage(data: mantra.image!) :
                                                        UIImage(named: Constants.defaultImage))!)
                                        .resizable()
                                        .frame(width: 41, height: 41, alignment: .center)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
}
