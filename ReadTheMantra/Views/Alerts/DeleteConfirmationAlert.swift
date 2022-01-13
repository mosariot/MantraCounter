//
//  DeleteConfirmationAlert.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 23.12.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

extension AlertCenter {
    
    @MainActor
    static func confirmDeletion(in vc: UIViewController, for mantra: Mantra, idiom: UIUserInterfaceIdiom) async -> Bool {
        await withCheckedContinuation { [weak vc] continuation in
            
            let alert = UIAlertController(
                title: NSLocalizedString("Delete Mantra",
                                         comment: "Alert Title on MantraViewController"),
                message: NSLocalizedString("Are you sure you want to delete this mantra?",
                                           comment: "Alert Message on MantraViewController"),
                preferredStyle: idiom == .phone ? .actionSheet : .alert)
            let deleteAction = UIAlertAction(
                title: NSLocalizedString("Delete", comment: "Alert Button on MantraViewController"),
                style: .destructive) { _ in
                    continuation.resume(returning: true)
                }
            let cancelAction = UIAlertAction(
                title: NSLocalizedString("Cancel", comment: "Alert Button on MantraViewController"),
                style: .cancel) { _ in
                    continuation.resume(returning: false)
                }
            alert.addAction(cancelAction)
            alert.addAction(deleteAction)
            alert.view.tintColor = Constants.accentColor ?? .systemOrange
            
            vc?.present(alert, animated: true, completion: nil)
        }
    }
}
