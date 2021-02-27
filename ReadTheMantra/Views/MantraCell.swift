//
//  MantraCell.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 27.02.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

class MantraCell: UICollectionViewListCell {
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        
        var backgroundConfig = UIBackgroundConfiguration.listGroupedCell().updated(for: state)
        backgroundConfig.cornerRadius = 15
        
        if (state.isHighlighted || state.isSelected) &&
            (traitCollection.userInterfaceIdiom == .pad || traitCollection.userInterfaceIdiom == .mac) {
            backgroundConfig.backgroundColor = Constants.accentColor
        }
        
        self.backgroundConfiguration = backgroundConfig
    }
}
