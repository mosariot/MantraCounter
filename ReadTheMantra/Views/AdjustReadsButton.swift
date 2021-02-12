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
    
    private func setupButtonImage(forSystemName systemName: String) {
        let buttonSize: CGFloat = traitCollection.userInterfaceIdiom == .pad ? 50 : 40
        let largeConfig = UIImage.SymbolConfiguration(pointSize: buttonSize, weight: .light, scale: .large)
        let buttonImage = UIImage(systemName: systemName, withConfiguration: largeConfig)?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal)
        setImage(buttonImage, for: .normal)
    }
}
