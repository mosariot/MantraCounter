//
//  DuplicatingAlertForPreloadedMantras.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 08.04.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

extension AlertControllerFactory {
    
    static func duplicatingAlertForPreloadedMantras(_ sender: UIBarButtonItem?, addPreloadedMantraHandler: @escaping () -> ()) -> UIAlertController {
        let alert = UIAlertController(
            title: NSLocalizedString("Duplicating Mantras",
                                     comment: "Alert Title for Duplication"),
            message: NSLocalizedString("One of selected mantras is already in your mantra list. Add anyway?",
                                       comment: "Alert Message for Duplication"),
            preferredStyle: .actionSheet)
        let addAction = UIAlertAction(
            title: NSLocalizedString("Add", comment: "Alert Button"),
            style: .default) { _ in
            addPreloadedMantraHandler()
        }
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("Cancel", comment: "Alert Button"),
            style: .cancel)
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        alert.view.tintColor = Constants.accentColor ?? .systemOrange
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = sender
          }
        
        return alert
    }
}
