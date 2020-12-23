//
//  DeleteConfirmationAlert.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 23.12.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    static func deleteConfirmationAlert(for mantra: Mantra, deleteActionHandler: @escaping (Mantra) -> ()) -> UIAlertController {
        let alert = UIAlertController(title: nil,
                                      message: NSLocalizedString("Are you sure you want to delete this mantra?", comment: "Alert Message on MantraViewController"),
                                      preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", comment: "Alert Button on MantraViewController"),
                                         style: .destructive) { action in
            deleteActionHandler(mantra)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert Button on MantraViewController"),
                                         style: .default, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        return alert
    }
}
