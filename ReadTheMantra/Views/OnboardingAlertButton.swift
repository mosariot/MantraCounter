//
//  AdjustReadsButton.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 02.12.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

@IBDesignable
final class OnboardingAlertButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.height / 2
    }
}
