//
//  WidgetModel.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 19.12.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import Foundation

struct WidgetModel: Identifiable, Codable {
    var id = UUID()
    let overallReads: Int32
    let favorites: [Item]
    let mantras: [Item]
    
    struct Item: Identifiable, Codable {
        var id = UUID()
        let title: String
        let reads: Int32
    }
}
