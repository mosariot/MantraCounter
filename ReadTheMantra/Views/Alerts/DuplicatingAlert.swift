//
//  DuplicatingAlert.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 23.12.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

extension AlertControllerFactory {
    
    static func duplicatingAlert(_ sender: UIBarButtonItem?, addPreloadedMantraHandler: @escaping () -> (),
                                 cancelActionHandler: @escaping () -> ()) -> UIAlertController {
        let alert = UIAlertController(
            title: NSLocalizedString("Duplicating Mantra",
                                     comment: "Alert Title for Duplication"),
            message: NSLocalizedString("It's already in your mantra list. Add another one?",
                                       comment: "Alert Message for Duplication"),
            preferredStyle: .actionSheet)
        let addAction = UIAlertAction(
            title: NSLocalizedString("Add", comment: "Alert Button"),
            style: .default) { _ in
            addPreloadedMantraHandler()
        }
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("Cancel", comment: "Alert Button"),
            style: .cancel) { _ in
            cancelActionHandler()
        }
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        alert.view.tintColor = Constants.accentColor ?? .systemOrange
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = sender
          }
        
        return alert
    }
}
