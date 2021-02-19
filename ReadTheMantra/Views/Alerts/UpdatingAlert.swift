//
//  UpdatingAlert.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 23.12.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    static func UpdatingAlert(mantra: Mantra,
                              updatingType: UpdatingType,
                              positiveActionHanlder: @escaping (Int32) -> ()) -> UIAlertController {
        
        func isValidUpdatingNumber(text: String?, updatingType: UpdatingType) -> Bool {
            guard
                let alertText = text,
                let alertNumber = UInt32(alertText)
            else { return false }
            
            switch updatingType {
            case .goal, .properValue:
                return 0...1_000_000 ~= alertNumber
            case .reads:
                return 0...1_000_000 ~= UInt32(mantra.reads) + alertNumber
            case .rounds:
                return 0...1_000_000 ~= UInt32(mantra.reads) + alertNumber * 108
            }
        }
        
        func alertAndActionTitles(for updatingType: UpdatingType) -> (String, String) {
            switch updatingType {
            case .goal:
                return (NSLocalizedString("Set a New Readings Goal", comment: "Alert Title on ReadsCountViewController"),
                        NSLocalizedString("Set", comment: "Alert Button on ReadsCountViewController"))
            case .rounds:
                return (NSLocalizedString("Enter Rounds Number", comment: "Alert Title on ReadsCountViewController"),
                        NSLocalizedString("Add", comment: "Alert Button on ReadsCountViewController"))
            case .reads:
                return (NSLocalizedString("Enter Readings Number", comment: "Alert Title on ReadsCountViewController"),
                        NSLocalizedString("Add", comment: "Alert Button on ReadsCountViewController"))
            case .properValue:
                return (NSLocalizedString("Set a New Readings Count", comment: "Alert Title on ReadsCountViewController"),
                        NSLocalizedString("Set", comment: "Alert Button on ReadsCountViewController"))
            }
        }
        
        var value: Int32 = 0
        let (alertTitle, actionTitle) = alertAndActionTitles(for: updatingType)
        
        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        let positiveAction = UIAlertAction(title: actionTitle, style: .default) { _ in
            positiveActionHanlder(value)
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = NSLocalizedString("Enter number", comment: "Alert Placehonder on ReadsCountViewController")
            alertTextField.keyboardType = .numberPad
            positiveAction.isEnabled = false
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alertTextField, queue: .main) { _ in
                if isValidUpdatingNumber(text: alertTextField.text, updatingType: updatingType) {
                    positiveAction.isEnabled = true
                    guard
                        let textValue = alertTextField.text,
                        let numberValue = Int32(textValue)
                    else { return }
                    value = numberValue
                } else {
                    positiveAction.isEnabled = false
                }
            }
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert Button on ReadsCountViewController"),
                                         style: .default,
                                         handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(positiveAction)
        alert.view.tintColor = Constants.accentColor ?? .systemOrange
        
        return alert
    }
}
