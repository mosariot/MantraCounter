//
//  MediumWidgetView.swift
//  FavoritesWidgetExtension
//
//  Created by Alex Vorobiev on 21.03.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import WidgetKit
import SwiftUI

struct MediumWidget: View {
    
    var widgetModel: WidgetModel
    
    @ViewBuilder
    var body: some View {
        let mantraArray = widgetModel.mantras.prefix(4)
        
        ZStack {
            Color.init(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            if mantraArray.count == 0 {
                Image("DefaultImage")
                    .resizable()
                    .frame(width: 100, height: 100, alignment: .center)
            } else {
                HStack {
                    ForEach(mantraArray, id: \.self) { mantra in
                        Link(destination: URL(string: "\(mantra.id)")!) {
                            VStack {
                                Image(uiImage: ((mantra.image != nil) ?
                                                    UIImage(data: mantra.image!) :
                                                    UIImage(named: Constants.defaultImage))!)
                                    .resizable()
                                    .frame(width: 55, height: 55, alignment: .center)
                                Text(mantra.title)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .frame(height: 33)
                                    .font(Font(UIFont.preferredFont(for: .footnote, weight: .semibold)))
                                Text(Int(mantra.reads).formattedNumber())
                                    .font(Font(UIFont.preferredFont(for: .caption1, weight: .bold)))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding()
            }
        }
    }
}
