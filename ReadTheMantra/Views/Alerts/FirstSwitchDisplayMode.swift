//
//  FirstSwitchDisplayMode.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 30.06.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

extension AlertControllerFactory {
    
    static func firstSwitchDisplayMode() -> UIAlertController {
        
        let alert = UIAlertController(
            title: NSLocalizedString("'Mantra Counter' Mode",
                                     comment: "Alert Title for first switch display mode"),
            message: NSLocalizedString("You have entered the 'Mantra Counter' mode. Single tap on the screen will add one reading, double tap will add one round. The screen will not dim. The edit buttons at the bottom are disabled.",
                                       comment: "Alert Message for first switch display mode"),
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        alert.view.tintColor = Constants.accentColor ?? .systemOrange
        return alert
    }
}
