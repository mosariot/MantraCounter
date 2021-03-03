//
//  NoImageAlert.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 23.12.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    static func noImageAlert(okActionHandler: @escaping () -> ()) -> UIAlertController {
        let alert = UIAlertController(title: "",
                                      message: NSLocalizedString("It seems like this photo is unavailable. Try to pick another one",
                                                                 comment: "Alert Message for unavailable photo"),
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            okActionHandler()
        }
        alert.addAction(okAction)
        alert.view.tintColor = Constants.accentColor ?? .systemOrange
        return alert
    }
}
