//
//  AddTitleAlert.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 21.03.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

extension AlertCenter {
    
    static func showAddTitleAlert(in vc: UIViewController) {
        let alert = UIAlertController(
            title: NSLocalizedString("Please add some title to mantra",
                                     comment: "Alert Title for add missing title"),
            message: nil,
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        alert.view.tintColor = Constants.accentColor ?? .systemOrange
        vc.present(alert, animated: true, completion: nil)
    }
}
