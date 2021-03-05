//
//  DuplicatingAlert.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 23.12.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    static func duplicatingAlert(addPreloadedMantraHandler: @escaping () -> (),
                                 cancelActionHandler: @escaping () -> ()) -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("Duplicating Mantra",
                                                               comment: "Alert Title for Duplication"),
                                      message: NSLocalizedString("It's already in your mantra list. Add another one?",
                                                                 comment: "Alert Message for Duplication"),
                                      preferredStyle: .alert)
        let addAction = UIAlertAction(title: NSLocalizedString("Add", comment: "Alert Button"),
                                      style: .default) { _ in
            addPreloadedMantraHandler()
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert Button"),
                                         style: .default) { _ in
            cancelActionHandler()
        }
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        alert.view.tintColor = Constants.accentColor ?? .systemOrange
        return alert
    }
}
