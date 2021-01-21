//
//  CollectionViewDataSource.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 22.12.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

final class CollectionViewDataSourceManager {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Mantra>
    
    var isInFavoriteMode = false
    
    func makeDataSource(collectionView: UICollectionView,
                        favoriteActionHandler: @escaping (Mantra) -> (),
                        deleteActionHandler: @escaping (Mantra) -> (),
                        canReorderingHandler: @escaping () -> Bool,
                        reorderingHandler: @escaping (NSDiffableDataSourceSnapshot<Int, Mantra>) -> ()) -> DataSource {
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Mantra> { [weak self] (cell, indexPath, mantra) in
            guard let self = self else { return }
            
            var content = UIListContentConfiguration.subtitleCell()
            content.text = mantra.title
            
            if (content.text != "") {
                content.secondaryText = NSLocalizedString("Current readings:", comment: "Current readings count") + " \(mantra.reads)"
                content.secondaryTextProperties.color = .secondaryLabel
                content.textToSecondaryTextVerticalPadding = 4
                content.image = (mantra.imageForTableView != nil) ?
                    UIImage(data: mantra.imageForTableView!) :
                    UIImage(named: Constants.defaultImage)?.resize(to: CGSize(width: Constants.rowHeight,
                                                                              height: Constants.rowHeight))
            }
            cell.contentConfiguration = content
            
            var background = UIBackgroundConfiguration.listGroupedCell()
            background.cornerRadius = 15
            cell.backgroundConfiguration = background
            
            // accessories configuration
            let favoriteAction = UIAction(image: UIImage(systemName: mantra.isFavorite ? "star.slash" : "star"),
                                          handler: { _ in favoriteActionHandler(mantra) })
            let favoriteButton = UIButton(primaryAction: favoriteAction)
            let favoriteAccessoryConfiguration = UICellAccessory.CustomViewConfiguration(customView: favoriteButton,
                                                                                         placement: .leading(displayed: .whenEditing))
            let favoriteAccessory = UICellAccessory.customView(configuration: favoriteAccessoryConfiguration)
            let deleteAccessory = UICellAccessory.delete(displayed: .whenEditing,
                                                         actionHandler: { deleteActionHandler(mantra) })
            let disclosureIndicatorAccessory = UICellAccessory.disclosureIndicator()
            let reorderAccessory = UICellAccessory.reorder(displayed: .whenEditing)
            let badge = UIImage(systemName: "checkmark.circle.fill",
                                withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?
                .withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
            let badgeConfiguration = UICellAccessory.CustomViewConfiguration(customView: UIImageView(image: badge),
                                                                             placement: .trailing(displayed: .always),
                                                                             isHidden: mantra.readsGoal > mantra.reads)
            let badgeAccessory = UICellAccessory.customView(configuration: badgeConfiguration)

            let accessories = self.isInFavoriteMode ?
                [favoriteAccessory, disclosureIndicatorAccessory, badgeAccessory, reorderAccessory] :
                [deleteAccessory, favoriteAccessory, disclosureIndicatorAccessory, badgeAccessory, reorderAccessory]

            cell.accessories = accessories
        }
        
        let dataSource = DataSource(collectionView: collectionView) { (collectionView, indexPath, mantra) -> UICollectionViewCell? in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: mantra)
        }
        
        dataSource.reorderingHandlers.canReorderItem = { _ -> Bool in
            return canReorderingHandler()
        }
        
        dataSource.reorderingHandlers.didReorder = { transaction in
            let snapshot = transaction.finalSnapshot
            reorderingHandler(snapshot)
        }
        return dataSource
    }
}
