//
//  StringFormattedWithSpaces.swift
//  ReadTheMantra
//
//  Created by Александр Воробьев on 17.09.2020.
//  Copyright © 2020 Александр Воробьев. All rights reserved.
//

import Foundation

extension Int {
    
    func stringFormattedWithSpaces() -> String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}
