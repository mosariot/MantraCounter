//
//  ButtonStackView.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 29.09.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

class ButtonStackView: UIStackView {
    init(with mantra: Mantra, previousReadsCount: Int32?,
         undoButtonHandler: @escaping () -> (),
         infoButtonHandler: @escaping () -> (),
         favoriteButtonHandler: @escaping () -> ()) {
        super.init(frame: .zero)
        let undoButton = UIButton(primaryAction: UIAction(handler: { _ in
            undoButtonHandler()
        }))
        undoButton.setImage(UIImage(systemName: "arrow.uturn.backward.circle"), for: .normal)
        undoButton.isEnabled = previousReadsCount != nil
        
        let infoButton = UIButton(
            type: .infoLight,
            primaryAction: UIAction(handler: { _ in
                infoButtonHandler()
            }))
        
        let star = mantra.isFavorite ? "star.fill" : "star"
        
        let favoriteButton = UIButton(primaryAction: UIAction(handler: { _ in
            favoriteButtonHandler()
        }))
        favoriteButton.setImage(UIImage(systemName: star), for: .normal)
        
        addArrangedSubview(undoButton)
        addArrangedSubview(favoriteButton)
        addArrangedSubview(infoButton)
        distribution = .equalSpacing
        axis = .horizontal
        alignment = .center
        spacing = 25
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
