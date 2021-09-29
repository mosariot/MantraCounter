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
        onboardingView.setup()
        
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
