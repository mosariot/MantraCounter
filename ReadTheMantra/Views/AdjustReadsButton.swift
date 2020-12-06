//
//  AdjustReadsButton.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 02.12.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

@IBDesignable
final class AdjustReadsButton: UIButton {
    
    public var imageSystemName = "" {
        didSet {
            setupButtonImage(forSystemName: imageSystemName)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    private func setupButtonImage(forSystemName systemName: String) {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .light, scale: .large)
        let largeReadings = UIImage(systemName: systemName, withConfiguration: largeConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        setImage(largeReadings, for: .normal)
    }
}
