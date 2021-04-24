//
//  FirstSearchOnTheInternetAlert.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 15.01.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    static func firstSearchOnTheInternetAlert() -> UIAlertController {
        
        let alert = UIAlertController(
            title: NSLocalizedString("Pick Photo",
                                     comment: "Alert Title for first search on the Internet"),
            message: NSLocalizedString("Just longpress on the image you liked, choose 'Copy' in contextual menu and confirm by 'Done'",
                                       comment: "Alert Message for first search on the Internet"),
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        alert.view.tintColor = Constants.accentColor ?? .systemOrange
        return alert
    }
}
