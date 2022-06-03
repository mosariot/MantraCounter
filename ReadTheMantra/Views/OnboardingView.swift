//
//  OnboardingView.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 29.06.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

final class OnboardingView: UIView {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var dismissButton: UIButton!
    @IBOutlet var image: UIImageView!
    
    func setup() {
        titleLabel.font = UIFont.preferredFont(for: .title1, weight: .heavy)
        titleLabel.text = NSLocalizedString("Welcome to the path of Enlightenment!", comment: "Onboarding Alert Title")
        dismissButton.titleLabel?.font = UIFont.preferredFont(for: .callout, weight: .bold)
        dismissButton.layer.cornerRadius = dismissButton.bounds.height / 4
        dismissButton.setTitle(NSLocalizedString("UNDERSTAND!", comment: "Onboarding Alert Button"), for: .normal)
        textLabel.text = NSLocalizedString("""
                                    Recitation of mantras is a sacrament.
                                    Approach this issue with all your awareness.
                                    In order for the practice of reciting the mantra to be correct, one must receive the transmission of the mantra from the teacher. Transmission is essential to maintain the strength of the original source of the mantra. It’s not enough just to read it in a book or on the Internet.
                                    For this reason, at start application doesn't include the mantra texts themselves (except Vajrasattva). They must be given to you by your spiritual mentor and can be added manually later.
                                    We wish you deep awarenesses and spiritual growth!
                                    """, comment: "Onboarding Alert Message")
    }
}
