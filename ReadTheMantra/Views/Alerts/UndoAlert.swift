//
//  UndoingAlert.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 02.03.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

extension AlertCenter {
    
    @MainActor
    static func confirmUndo(in vc: UIViewController) async -> Bool {
        await withCheckedContinuation { continuation in
            let alert = UIAlertController(
                title: NSLocalizedString("Undo Changes",
                                         comment: "Alert Title for Undo Action"),
                message: NSLocalizedString("Are you sure you want to revert last readings count changes?",
                                           comment: "Alert Message for Undo Action"),
                preferredStyle: .alert)
            let okAction = UIAlertAction(
                title: NSLocalizedString("Yes", comment: "Alert Button on ReadsCountViewController"),
                style: .default) { _ in
                    continuation.resume(returning: true)
                }
            let cancelAction = UIAlertAction(title: NSLocalizedString("No", comment: "Alert Button on ReadsCountViewController"),
                                             style: .cancel) { _ in
                continuation.resume(returning: false)
            }
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            alert.view.tintColor = Constants.accentColor ?? .systemOrange
            vc.present(alert, animated: true, completion: nil)
        }
    }
}
