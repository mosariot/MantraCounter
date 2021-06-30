//
//  SmallWidgetView.swift
//  FavoritesWidgetExtension
//
//  Created by Alex Vorobiev on 21.03.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import WidgetKit
import SwiftUI

struct SmallWidget: View {
    
    var widgetModel: WidgetModel
    
    var body: some View {
        
        let mantraArray = widgetModel.mantras.prefix(4)
        
        ZStack {
            Color.init(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            if mantraArray.count == 0 {
                Image(Constants.defaultImage)
                    .resizable()
                    .frame(width: 100, height: 100, alignment: .center)
            } else {
                VStack {
                    ForEach(0 ..< 2, id: \.self) { row in
                        HStack {
                            ForEach(0 ..< 2, id: \.self) { column in
                                VStack {
                                    if (2 * row + column) < mantraArray.count {
                                        Image(uiImage: ((mantraArray[2 * row + column].image != nil) ?
                                                            UIImage(data: mantraArray[2 * row + column].image!) :
                                                            UIImage(named: Constants.defaultImage))!)
                                            .resizable()
                                            .frame(width: 43, height: 43, alignment: .center)
                                        Text(Int(mantraArray[2 * row + column].reads).formattedNumber())
                                            .font(Font(UIFont.preferredFont(for: .caption2, weight: .bold)))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
}
