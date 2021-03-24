//
//  CancelNewMantraAlert.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 21.03.2021.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    static func cancelNewMantraAlert(idiom: UIUserInterfaceIdiom, addPreloadedMantraHandler: @escaping () -> (),
                                 cancelActionHandler: @escaping () -> ()) -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("Save changes",
                                                               comment: "Alert Title for Cancel New Mantra"),
                                      message: NSLocalizedString("Do you want to save this mantra?",
                                                                 comment: "Alert Message for Cancel New Mantra"),
                                      preferredStyle: idiom == .phone ? .actionSheet : .alert)
        let addAction = UIAlertAction(title: NSLocalizedString("Save", comment: "Alert Button"),
                                      style: .default) { _ in
            addPreloadedMantraHandler()
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert Button"),
                                         style: .cancel) { _ in
            cancelActionHandler()
        }
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        alert.view.tintColor = Constants.accentColor ?? .systemOrange
        return alert
    }
}
