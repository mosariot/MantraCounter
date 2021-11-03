//
//  NumberValidation.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 02.11.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import Foundation

extension String {
    
    func isValidUpdatingNumber(with updatingType: AdjustingType, and currentReads: Int32) -> Bool {
        guard let alertNumber = UInt32(self) else { return false }
        switch updatingType {
        case .goal, .properValue:
            return 0...1_000_000 ~= alertNumber
        case .reads:
            return 0...1_000_000 ~= UInt32(currentReads) + alertNumber
        case .rounds:
            return 0...1_000_000 ~= UInt32(currentReads) + alertNumber * 108
        }
    }
}
