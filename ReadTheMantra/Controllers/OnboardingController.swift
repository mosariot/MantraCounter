//
//  OnboardingController.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 06.12.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

protocol OnboardingControllerDelegate: class {
    func dismissButtonPressed()
}

final class OnboardingController: UIViewController {
    
    weak var delegate: OnboardingControllerDelegate?
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var dismissButton: OnboardingAlertButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isModalInPresentation = true
        setupText()
    }
    
    private func setupText() {
        titleLabel.font = UIFont.preferredFont(for: .title1, weight: .semibold)
        dismissButton.titleLabel?.font = UIFont.preferredFont(for: .callout, weight: .bold)
        titleLabel.text = NSLocalizedString("Welcome to the path of Enlightenment!", comment: "Onboarding Alert Title")
        textLabel.text = NSLocalizedString("""
                                    Recitation of mantras - is a sacrament.
                                    Approach this issue with all your awareness.
                                    For this reason, application doesn't include the mantra texts themselves.
                                    They must be given to you by your spiritual mentor.
                                    We wish you deep awarenesses and spiritual growth!
                                    """, comment: "Onboarding Alert Message")
        dismissButton.setTitle(NSLocalizedString("UNDERSTAND!", comment: "Onboarding Alert Button"), for: .normal)
    }
    
    @IBAction private func dismissButtonPressed(_ sender: OnboardingAlertButton) {
        dismiss(animated: true, completion: nil)
        delegate?.dismissButtonPressed()
    }
}
