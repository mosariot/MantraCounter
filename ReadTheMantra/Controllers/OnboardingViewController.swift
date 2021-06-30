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
    
    private var onboardingView: OnboardingView! {
        guard isViewLoaded else { return nil }
        return (view as! OnboardingView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
    
    private func setupUI() {
        onboardingView.titleLabel.font = UIFont.preferredFont(for: .title1, weight: .heavy)
        onboardingView.titleLabel.text = NSLocalizedString("Welcome to the path of Enlightenment!", comment: "Onboarding Alert Title")
        onboardingView.dismissButton.titleLabel?.font = UIFont.preferredFont(for: .callout, weight: .bold)
        onboardingView.dismissButton.layer.cornerRadius = onboardingView.dismissButton.bounds.height / 4
        onboardingView.dismissButton.setTitle(NSLocalizedString("UNDERSTAND!", comment: "Onboarding Alert Button"), for: .normal)
        onboardingView.textLabel.text = NSLocalizedString("""
                                    Recitation of mantras - is a sacrament.
                                    Approach this issue with all your awareness.
                                    In order for the practice of reciting the mantra to be correct, one must receive the transmission of the mantra from the teacher. Transmission is essential to maintain the strength of the original source of the mantra. It is not enough just to read it in a book or on the Internet.
                                    For this reason, at start application doesn't include the mantra texts themselves (except Vajrasattva). They must be given to you by your spiritual mentor and can be added manually later.
                                    We wish you deep awarenesses and spiritual growth!
                                    """, comment: "Onboarding Alert Message")
        
        if UIDevice.modelName == "iPhone SE" || UIDevice.modelName == "iPod touch (7th generation)" {
            onboardingView.titleLabel.font = UIFont.preferredFont(for: .title2, weight: .heavy)
            onboardingView.textLabel.font = .preferredFont(for: .subheadline, weight: .regular)
            onboardingView.image.isHidden = true
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
                    self.onboardingView.titleLabel.font = UIFont.preferredFont(for: .title2, weight: .heavy)
                    self.onboardingView.textLabel.font = .preferredFont(for: .subheadline, weight: .regular)
                    self.onboardingView.image.isHidden = true
                }
            }
        })
    }
}
