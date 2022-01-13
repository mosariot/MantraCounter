//
//  CancelMantraAlert.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 28.11.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

extension AlertCenter {
    
    @MainActor
    static func confirmCancelMantra(in vc: UIViewController, with sender: UIBarButtonItem?) async -> Bool {
        await withCheckedContinuation { [weak vc] continuation in
            
            let alert = UIAlertController(
                title: nil,
                message: NSLocalizedString("Are you sure you want to discard this Mantra?",
                                           comment: "Alert Message for Cancel New Mantra"),
                preferredStyle: .actionSheet)
            let dontSaveAction = UIAlertAction(
                title: NSLocalizedString("Discard Mantra", comment: "Alert Button"),
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
            
            vc?.present(alert, animated: true, completion: nil)
        }
    }
}
