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
        didSet { setupButtonImage(forSystemName: imageSystemName) }
    }
    
    private func setupButtonImage(forSystemName systemName: String) {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .light, scale: .large)
        let buttonImage = UIImage(systemName: systemName, withConfiguration: largeConfig)?.withTintColor(UIColor(named: "Accent") ?? .systemOrange, renderingMode: .alwaysOriginal)
        setImage(buttonImage, for: .normal)
        layer.shadowColor = UIColor(.black).cgColor
        layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 2.0
    }
}
