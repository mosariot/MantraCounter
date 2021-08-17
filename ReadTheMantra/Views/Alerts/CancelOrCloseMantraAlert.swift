//
//  CancelOrCloseMantraAlert.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 21.03.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    static func cancelOrCloseMantraAlert(_ sender: UIBarButtonItem?, dontSaveActionHandler: @escaping () -> ()) -> UIAlertController {
        let alert = UIAlertController(
            title: nil,
            message: NSLocalizedString("Are you sure you want to discard changes?",
                                       comment: "Alert Message for Cancel New Mantra"),
            preferredStyle: .actionSheet)
        let dontSaveAction = UIAlertAction(
            title: NSLocalizedString("Discard Changes", comment: "Alert Button"),
            style: .destructive) { _ in
            dontSaveActionHandler()
        }
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("Cancel", comment: "Alert Button"),
            style: .cancel)
        alert.addAction(dontSaveAction)
        alert.addAction(cancelAction)
        alert.view.tintColor = Constants.accentColor ?? .systemOrange
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = sender
          }
        
        return alert
    }
}
