//
//  NotNegativePropertyWrapper.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 10.11.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import Foundation

@propertyWrapper
struct NotNegative {
    private var value: Int
    private static func clamped(_ input: Int) -> Int {
        input >= 0 ? input : 0
    }
    init(wrappedValue: Int) {
        value = Self.clamped(wrappedValue)
    }
    var wrappedValue: Int {
        get { value }
        set { value = Self.clamped(newValue) }
    }
}
