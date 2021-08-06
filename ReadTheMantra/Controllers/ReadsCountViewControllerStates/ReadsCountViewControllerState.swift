//
//  ReadsCountViewControllerState.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 04.08.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

protocol ReadsCountViewControllerState: AnyObject {
    
    func apply(to context: ReadsCountViewController)
}
