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
        
        let mantraArray = Array(entry.widgetModel.mantras.prefix(4))
        let columns: [GridItem] = [GridItem(.flexible()),
                                   GridItem(.flexible())]
        
        GeometryReader { gp in
            ZStack {
                Color.init(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if mantraArray.count == 0 {
                    Image(Constants.defaultImage)
                        .resizable()
                        .frame(width: 100, height: 100, alignment: .center)
                } else {
                    LazyVGrid(columns: columns, alignment: .center, spacing: 7, content: {
                        ForEach(mantraArray, id: \.self) { mantra in
                            VStack(spacing: 2) {
                                Image(uiImage: ((mantra.image != nil) ?
                                                    UIImage(data: mantra.image!) :
                                                    UIImage(named: Constants.defaultImage))!)
                                    .resizable()
                                    .frame(width: gp.size.width/3.4, height: gp.size.height/3.4, alignment: .center)
                                Text(Int(mantra.reads).stringFormattedWithSpaces())
                                    .font(Font(UIFont.preferredFont(for: .footnote, weight: .bold)))
                                    .foregroundColor(.secondary)
                            }
                        }
                    })
                    .padding(.horizontal)
                }
            }
        }
    }
}
