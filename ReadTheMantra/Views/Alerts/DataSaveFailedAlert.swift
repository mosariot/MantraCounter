//
//  DataSaveFailedAlert.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 04.01.2022.
//  Copyright © 2022 Alex Vorobiev. All rights reserved.
//

import UIKit

extension AlertCenter {
    
    static func dataSaveFailedAlert(in vc: UIViewController) {
        let message = NSLocalizedString("There was a fatal error in the app and it cannot continue. Press OK to terminate the app. Sorry for inconvenience.",
                                        comment: "Core Data Fatal Error Message")
        let alert = UIAlertController(
            title: NSLocalizedString("Internal Error", comment: "Internal Error"),
            message: message,
            preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            let exception = NSException(name: NSExceptionName.internalInconsistencyException, reason: "Fatal Core Data error", userInfo: nil)
            exception.raise()
        }
        alert.addAction(action)
        alert.view.tintColor = Constants.accentColor ?? .systemOrange
        vc.present(alert, animated: true, completion: nil)
    }
}
