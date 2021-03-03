//
//  NoImageAlert.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 02.03.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    static func undoAlert(okActionHandler: @escaping () -> ()) -> UIAlertController {
        let alert = UIAlertController(title: "",
                                      message: NSLocalizedString("Are you shure you want to revert last readings count changes?",
                                                                 comment: "Alert Message for Undo Action"),
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Yes", comment: "Alert Button on ReadsCountViewController"),
                                     style: .default) { _ in
            okActionHandler()
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("No", comment: "Alert Button on ReadsCountViewController"),
                                         style: .default, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        alert.view.tintColor = Constants.accentColor ?? .systemOrange
        return alert
    }
}
