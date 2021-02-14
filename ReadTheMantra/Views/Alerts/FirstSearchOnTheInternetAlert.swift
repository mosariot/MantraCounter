//
//  FirstSearchOnTheInternetAlert.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 15.01.2021.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    static func firstSearchOnTheInternetAlert() -> UIAlertController {
        
        let alert = UIAlertController(title: nil,
                                      message: NSLocalizedString("Just longpress on the image you liked, choose 'Copy' in contextual menu and confirm by 'Done'",
                                                                 comment: "Alert Message for first search on the Internet"),
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        alert.view.tintColor = UIColor(named: "Accent") ?? .systemOrange
        return alert
    }
}
