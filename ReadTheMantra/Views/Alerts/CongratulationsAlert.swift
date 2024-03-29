//
//  CongratulationsAlert.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 23.12.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

extension AlertCenter {
    
    static func showCongratulationsAlert(in vc: UIViewController, level: Level) {
        
        func congratulationsAlertMessage(for level: Level) -> String {
            switch level {
            case .halfGoal:
                return NSLocalizedString("You're half way to your goal!", comment: "Alert Meassage on ReadsCountViewController")
            case .fullGoal:
                return NSLocalizedString("You've reached your goal!", comment: "Alert Message on ReadsCountViewController")
            }
        }
        
        let alert = UIAlertController(
            title: NSLocalizedString("Congratulations!", comment: "Alert Title on ReadsCountViewController"),
            message: congratulationsAlertMessage(for: level),
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        alert.view.tintColor = Constants.accentColor ?? .systemOrange
        
        vc.present(alert, animated: true, completion: nil)
    }
}
