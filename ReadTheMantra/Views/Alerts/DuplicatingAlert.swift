//
//  DuplicatingAlert.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 23.12.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

extension AlertCenter {
    
    @MainActor
    static func confirmDuplicationOfMantra(in vc: UIViewController, with sender: UIBarButtonItem?) async -> Bool {
        await withCheckedContinuation { [weak vc] continuation in
            
            let alert = UIAlertController(
                title: NSLocalizedString("Duplicating Mantra",
                                         comment: "Alert Title for Duplication"),
                message: NSLocalizedString("It's already in your mantra list. Add another one?",
                                           comment: "Alert Message for Duplication"),
                preferredStyle: .actionSheet)
            let addAction = UIAlertAction(
                title: NSLocalizedString("Add", comment: "Alert Button"),
                style: .default) { _ in
                    continuation.resume(returning: true)
                }
            let cancelAction = UIAlertAction(
                title: NSLocalizedString("Cancel", comment: "Alert Button"),
                style: .cancel) { _ in
                    continuation.resume(returning: false)
                }
            alert.addAction(cancelAction)
            alert.addAction(addAction)
            alert.view.tintColor = Constants.accentColor ?? .systemOrange
            
            if let popoverController = alert.popoverPresentationController {
                popoverController.barButtonItem = sender
            }
            
            vc?.present(alert, animated: true, completion: nil)
        }
    }
}
