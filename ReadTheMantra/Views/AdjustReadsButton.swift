//
//  AdjustReadsButton.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 02.12.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

final class AdjustReadsButton: UIButton {
    
    public var imageSystemName = "" {
        didSet {
            setupButtonImage(forSystemName: imageSystemName)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupRoundButton()
    }
    
    private func setupRoundButton() {
        layer.cornerRadius = 35
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        layer.shadowOffset = CGSize(width: 3, height: 3)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 3.0
    }
    
    private func setupButtonImage(forSystemName systemName: String) {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .light, scale: .large)
        let largeReadings = UIImage(systemName: systemName, withConfiguration: largeConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        setImage(largeReadings, for: .normal)
    }
}
