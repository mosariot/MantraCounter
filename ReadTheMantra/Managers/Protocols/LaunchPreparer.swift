//
//  LaunchPreparer.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 20.08.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import Foundation

protocol LaunchPreparer {
    
    func registerDefaults()
    mutating func checkForFirstLaunch()
}
