//
//  Functions.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 16.04.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import Foundation

func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}

let dataSaveFailedNotification = Notification.Name("DataSaveFailedNotification")
func fatalCoreDataError(_ error: Error) {
    print("*** Fatal error \(error)")
    NotificationCenter.default.post(name: dataSaveFailedNotification, object: nil)
}
