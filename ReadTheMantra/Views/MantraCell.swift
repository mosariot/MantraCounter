//
//  MantraCell.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 27.02.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

protocol DeleteMantraDelegate: class {
    func showDeleteConfirmationAlert(for: Mantra)
}

class MantraCell: UICollectionViewListCell {
    
    var mantra: Mantra? {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }
    weak var delegate: DeleteMantraDelegate?
    private var isPadOrMac: Bool {
        traitCollection.userInterfaceIdiom == .pad || traitCollection.userInterfaceIdiom == .mac
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        
        guard let mantra = mantra else { return }
        
        // Content Configuration
        var configuration = UIListContentConfiguration.subtitleCell().updated(for: state)
        configuration.text = mantra.title
        configuration.secondaryText = NSLocalizedString("Current readings:",
                                                        comment: "Current readings count") + " \(mantra.reads)"
        configuration.secondaryTextProperties.color = .secondaryLabel
        configuration.textToSecondaryTextVerticalPadding = 4
        configuration.image = (mantra.imageForTableView != nil) ?
            UIImage(data: mantra.imageForTableView!) :
            UIImage(named: Constants.defaultImage)?.resize(to: CGSize(width: Constants.rowHeight,
                                                                      height: Constants.rowHeight))
        
        // Background Configuration
        var backgroundConfig = UIBackgroundConfiguration.listGroupedCell().updated(for: state)
        backgroundConfig.cornerRadius = 15
        
        // Selecting and Highlighting
        if isPadOrMac {
            if state.isSelected {
                configuration.textProperties.color = .white
                configuration.secondaryTextProperties.color = .white
                backgroundConfig.backgroundColor = nil
            } else {
                backgroundConfig.backgroundColor = .secondarySystemGroupedBackground
            }
        }
        
        if state.isHighlighted {
            backgroundConfig.backgroundColor = Constants.accentColor?.withAlphaComponent(0.3)
        }
        
        contentConfiguration = configuration
        backgroundConfiguration = backgroundConfig
        
        // Accessories Setup
        let disclosureIndicatorAccessory = UICellAccessory.disclosureIndicator()
        
        if state.isEditing {
            let favoriteAction = UIAction(image: UIImage(systemName: mantra.isFavorite ? "star.slash" : "star")?
                                            .withTintColor((state.isHighlighted || state.isSelected) ? .white : Constants.accentColor ?? .systemOrange,
                                                           renderingMode: .alwaysOriginal),
                                          handler: { _ in
                                            mantra.isFavorite.toggle()})
            let favoriteButton = UIButton(primaryAction: favoriteAction)
            let favoriteAccessoryConfiguration = UICellAccessory.CustomViewConfiguration(customView: favoriteButton,
                                                                                         placement: .leading(displayed: .whenEditing))
            let favoriteAccessory = UICellAccessory.customView(configuration: favoriteAccessoryConfiguration)
            let deleteAccessory = UICellAccessory.delete(displayed: .whenEditing,
                                                         actionHandler: { [weak self] in
                                                            guard let self = self else { return }
                                                            self.delegate?.showDeleteConfirmationAlert(for: mantra) })
            let badge = UIImage(systemName: "checkmark.circle.fill",
                                withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?
                .withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
            let badgeConfiguration = UICellAccessory.CustomViewConfiguration(customView: UIImageView(image: badge),
                                                                             placement: .trailing(displayed: .always),
                                                                             isHidden: mantra.readsGoal > mantra.reads)
            let badgeAccessory = UICellAccessory.customView(configuration: badgeConfiguration)
            accessories = [deleteAccessory, favoriteAccessory, disclosureIndicatorAccessory, badgeAccessory]
        } else {
            let badge = UIImage(systemName: "checkmark.circle.fill",
                                withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?
                .withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
            let badgeConfiguration = UICellAccessory.CustomViewConfiguration(customView: UIImageView(image: badge),
                                                                             placement: .trailing(displayed: .always),
                                                                             isHidden: mantra.readsGoal > mantra.reads)
            let badgeAccessory = UICellAccessory.customView(configuration: badgeConfiguration)
            accessories = [disclosureIndicatorAccessory, badgeAccessory]
        }
    }
}
