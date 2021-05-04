//
//  OnboardingViewController.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 06.12.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

protocol OnboardingViewControllerDelegate: AnyObject {
    func dismissButtonPressed()
}

final class OnboardingViewController: UIViewController {
    
    weak var delegate: OnboardingViewControllerDelegate?
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var dismissButton: UIButton!
    @IBOutlet private weak var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
    
    private func setupUI() {
        titleLabel.font = UIFont.preferredFont(for: .title1, weight: .heavy)
        titleLabel.text = NSLocalizedString("Welcome to the path of Enlightenment!", comment: "Onboarding Alert Title")
        dismissButton.titleLabel?.font = UIFont.preferredFont(for: .callout, weight: .bold)
        dismissButton.layer.cornerRadius = dismissButton.bounds.height / 4
        dismissButton.setTitle(NSLocalizedString("UNDERSTAND!", comment: "Onboarding Alert Button"), for: .normal)
        textLabel.text = NSLocalizedString("""
                                    Recitation of mantras - is a sacrament.
                                    Approach this issue with all your awareness.
                                    In order for the practice of reciting the mantra to be correct, one must receive the transmission of the mantra from the teacher. Transmission is essential to maintain the strength of the original source of the mantra. It is not enough just to read it in a book or on the Internet.
                                    For this reason, at start application doesn't include the mantra texts themselves (except Vajrasattva). They must be given to you by your spiritual mentor and can be added manually later.
                                    We wish you deep awarenesses and spiritual growth!
                                    """, comment: "Onboarding Alert Message")
        
        if UIDevice.modelName == "iPhone SE" || UIDevice.modelName == "iPod touch (7th generation)" {
            titleLabel.font = UIFont.preferredFont(for: .title2, weight: .heavy)
            textLabel.font = .preferredFont(for: .subheadline, weight: .regular)
            image.isHidden = true
        }
    }
    
    @IBAction private func dismissButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        delegate?.dismissButtonPressed()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] context in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if UIDevice.modelName == "iPhone SE" || UIDevice.modelName == "iPod touch (7th generation)" {
                    self.titleLabel.font = UIFont.preferredFont(for: .title2, weight: .heavy)
                    self.textLabel.font = .preferredFont(for: .subheadline, weight: .regular)
                    self.image.isHidden = true
                }
            }
        })
    }
}
