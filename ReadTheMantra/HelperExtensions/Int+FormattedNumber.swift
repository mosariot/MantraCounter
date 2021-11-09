//
//  StringFormattedWithSpaces.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 17.09.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import Foundation

extension Int {
    
    func formattedNumber() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}
