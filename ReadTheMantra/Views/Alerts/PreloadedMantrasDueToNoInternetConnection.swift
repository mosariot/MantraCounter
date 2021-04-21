//
//  PreloadedMantrasDueToNoInternetConnection.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 20.04.2021.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    static func preloadedMantrasDueToNoInternetConnection() -> UIAlertController {
        let alert = UIAlertController(
            title: NSLocalizedString("No Internet Connection",
                                     comment: "Alert Title for preloading mantras due to no internet connection"),
            message: NSLocalizedString("It seems like there is no internet connection right now. New set of mantras was preloaded. If you were using 'Mantra Reader' previously with enabled iCloud account, your recordings will be added to the list automatically, when internet connection will be available (you may need to relaunch the app).",
                                       comment: "Alert Message for preloading mantras due to no internet connection"),
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        alert.view.tintColor = Constants.accentColor ?? .systemOrange
        return alert
    }
}
