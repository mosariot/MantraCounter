//
//  CloseMantraAlert.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 21.03.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

extension AlertCenter {
    
    @MainActor
    static func confirmDiscardChanges(in vc: UIViewController, with sender: UIBarButtonItem?) async -> Bool {
        await withCheckedContinuation { continuation in
            
            let alert = UIAlertController(
                title: nil,
                message: NSLocalizedString("Are you sure you want to discard changes?",
                                           comment: "Alert Message for discard changes"),
                preferredStyle: .actionSheet)
            let dontSaveAction = UIAlertAction(
                title: NSLocalizedString("Discard Changes", comment: "Alert Button"),
                style: .destructive) { _ in
                    continuation.resume(returning: true)
                }
            let cancelAction = UIAlertAction(
                title: NSLocalizedString("Cancel", comment: "Alert Button"),
                style: .cancel) { _ in
                    continuation.resume(returning: false)
                }
            alert.addAction(dontSaveAction)
            alert.addAction(cancelAction)
            alert.view.tintColor = Constants.accentColor ?? .systemOrange
            
            if let popoverController = alert.popoverPresentationController {
                popoverController.barButtonItem = sender
            }
            
            vc.present(alert, animated: true, completion: nil)
        }
    }
}
