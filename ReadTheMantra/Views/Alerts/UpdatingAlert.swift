//
//  UpdatingAlert.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 23.12.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

extension AlertControllerFactory {
    
    static func updatingAlert(mantra: Mantra,
                              updatingType: AdjustingType,
                              delegate: UITextFieldDelegate,
                              positiveActionHandler: @escaping (Int32) -> ()) -> UIAlertController {
        
        func alertAndActionTitles(for updatingType: AdjustingType) -> (String, String) {
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
            positiveActionHandler(value)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert Button on ReadsCountViewController"),
                                         style: .default)
        alert.addTextField { alertTextField in
            alertTextField.placeholder = NSLocalizedString("Enter number", comment: "Alert Placehonder on ReadsCountViewController")
            alertTextField.keyboardType = .numberPad
            alertTextField.clearButtonMode = .always
            alertTextField.delegate = delegate
            positiveAction.isEnabled = false
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alertTextField, queue: .main) { _ in
                if alertTextField.text!.isValidUpdatingNumber(with: updatingType, and: mantra.reads) {
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
        alert.addAction(cancelAction)
        alert.addAction(positiveAction)
        alert.view.tintColor = Constants.accentColor ?? .systemOrange
        
        return alert
    }
}
