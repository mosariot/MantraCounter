//
//  NoImageAlert.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 23.12.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

extension AlertCenter {
    
    @MainActor
    static func confirmNoValidImage(in vc: UIViewController) async -> Bool {
        await withCheckedContinuation { continuation in
            let alert = UIAlertController(
                title: NSLocalizedString("Unavailable Photo",
                                         comment: "Alert Title for unavailable photo"),
                message: NSLocalizedString("It seems like this photo is unavailable. Try to pick another one",
                                           comment: "Alert Message for unavailable photo"),
                preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                continuation.resume(returning: true)
            }
            alert.addAction(okAction)
            
            alert.view.tintColor = Constants.accentColor ?? .systemOrange
            vc.present(alert, animated: true, completion: nil)
        }
    }
}
