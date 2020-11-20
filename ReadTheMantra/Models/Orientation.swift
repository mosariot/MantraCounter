//
//  Orientation.swift
//  ReadTheMantra
//
//  Created by Александр Воробьев on 20.11.2020.
//  Copyright © 2020 Александр Воробьев. All rights reserved.
//

import UIKit

struct Orientation {
    static func lock(_ orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
}
