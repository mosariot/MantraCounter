//
//  MantraProtocol.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 23.08.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import Foundation

protocol MantraProtocol {
    
    var details: String? { get set }
    var image: Data? { get set }
    var imageForTableView: Data? { get set }
    var isFavorite: Bool { get set }
    var reads: Int32 { get set }
    var readsGoal: Int32 { get set }
    var text: String? { get set }
    var title: String? { get set }
    var uuid: UUID? { get set }
}

extension Mantra: MantraProtocol { }
