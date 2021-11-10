//
//  ReadsCountView.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 29.06.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

final class ReadsCountView: UIView {
    
    @IBOutlet var portraitMantraImageView: UIImageView!
    @IBOutlet var landscapeMantraImageView: UIImageView!
    @IBOutlet var titleLabel: CopyableLabel!
    @IBOutlet var addRoundsButton: AdjustReadsButton!
    @IBOutlet var addReadsButton: AdjustReadsButton!
    @IBOutlet var setProperValueButton: AdjustReadsButton!
    @IBOutlet var circularProgressView: CircularProgressView!
    @IBOutlet var readsGoalButton: UIButton!
    @IBOutlet var mainStackView: UIStackView!
    @IBOutlet var displayAlwaysOn: UIButton!
    
    func setup(with mantra: Mantra) {
        titleLabel.text = mantra.title
        titleLabel.font = UIFont.preferredFont(for: .largeTitle, weight: .medium)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.allowsDefaultTighteningForTruncation = true
        readsGoalButton.setTitle(NSLocalizedString("Goal: ",
                                                   comment: "Button on ReadsCountViewController") + Int(mantra.readsGoal).formattedNumber(),
                                                for: .normal)
        addReadsButton.imageSystemName = "plus.circle.fill"
        addRoundsButton.imageSystemName = "arrow.clockwise.circle.fill"
        setProperValueButton.imageSystemName = "hand.draw.fill"
    }
    
    func setPortraitMantraImage(with mantra: Mantra) {
        let image = (mantra.image != nil) ? UIImage(data: mantra.image!) : UIImage(named: Constants.defaultImage)
        let downsampledPortraitMantraImage = image?.resize(
            to: CGSize(width: portraitMantraImageView.bounds.width == 0 ? landscapeMantraImageView.bounds.width/1.5 : portraitMantraImageView.bounds.width,
                       height: portraitMantraImageView.bounds.height == 0 ? landscapeMantraImageView.bounds.height/1.5 : portraitMantraImageView.bounds.height))
        portraitMantraImageView.image = downsampledPortraitMantraImage
    }
    
    func setLandscapeMantraImage(with mantra: Mantra) {
        let image = (mantra.image != nil) ? UIImage(data: mantra.image!) : UIImage(named: Constants.defaultImage)
        let downsampledLandscapeMantraImage = image?.resize(
            to: CGSize(width: landscapeMantraImageView.bounds.width == 0 ? portraitMantraImageView.bounds.width*1.5 : landscapeMantraImageView.bounds.width,
                       height: landscapeMantraImageView.bounds.height == 0 ? portraitMantraImageView.bounds.height*1.5 : landscapeMantraImageView.bounds.height))
        landscapeMantraImageView.image = downsampledLandscapeMantraImage
    }
}
