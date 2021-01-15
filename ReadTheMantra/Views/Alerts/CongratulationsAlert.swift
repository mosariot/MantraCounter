//
//  CongratulationsAlert.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 23.12.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    static func congratulationsAlert(level: Level) -> UIAlertController {
        
        func congratulationsAlertTitle(for level: Level) -> String {
            switch level {
            case .halfGoal:
                return NSLocalizedString("""
                                        Congratulations!
                                        You're half way to your goal!
                                        """, comment: "Alert Title on ReadsCountViewController")
            case .fullGoal:
                return NSLocalizedString("""
                                        Congratulations!
                                        You've reached your goal!
                                        """, comment: "Alert Title on ReadsCountViewController")
            }
        }

        let alert = UIAlertController(title: congratulationsAlertTitle(for: level),
                                      message: nil,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        return alert
    }
}
