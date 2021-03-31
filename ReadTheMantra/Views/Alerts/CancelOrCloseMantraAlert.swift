//
//  CancelOrCloseMantraAlert.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 21.03.2021.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    static func cancelOrCloseMantraAlert(idiom: UIUserInterfaceIdiom, saveMantraHandler: @escaping () -> (),
                                 dontSaveActionHandler: @escaping () -> ()) -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("Save changes",
                                                               comment: "Alert Title for Cancel New Mantra"),
                                      message: NSLocalizedString("Do you want to save this mantra?",
                                                                 comment: "Alert Message for Cancel New Mantra"),
                                      preferredStyle: idiom == .phone ? .actionSheet : .alert)
        let saveAction = UIAlertAction(title: NSLocalizedString("Save", comment: "Alert Button"),
                                      style: .default) { _ in
            saveMantraHandler()
        }
        let dontSaveAction = UIAlertAction(title: NSLocalizedString("Don't save", comment: "Alert Button"),
                                         style: .default) { _ in
            dontSaveActionHandler()
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert Button"),
                                         style: .cancel)
        alert.addAction(saveAction)
        alert.addAction(dontSaveAction)
        alert.addAction(cancelAction)
        alert.view.tintColor = Constants.accentColor ?? .systemOrange
        return alert
    }
}
