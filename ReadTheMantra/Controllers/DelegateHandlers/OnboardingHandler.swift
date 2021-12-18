//
//  OnboardingHandler.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 28.11.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

final class OnboardingHandler {
    
    private var continuation: CheckedContinuation<Bool, Never>?
    private var caller: UIViewController
    private var isPadOrMacIdiom: Bool {
        caller.traitCollection.userInterfaceIdiom == .pad || caller.traitCollection.userInterfaceIdiom == .mac
    }
    private var isPhoneIdiom: Bool {
        caller.traitCollection.userInterfaceIdiom == .phone
    }
    
    init(caller: UIViewController) {
        self.caller = caller
        if let onboardingViewController = caller.storyboard?.instantiateViewController(
            identifier: Constants.onboardingViewController) as? OnboardingViewController {
            onboardingViewController.delegate = self
            if isPhoneIdiom {
                onboardingViewController.modalPresentationStyle = .fullScreen
            } else if isPadOrMacIdiom {
                onboardingViewController.modalTransitionStyle = .crossDissolve
            }
            caller.present(onboardingViewController, animated: true)
        }
    }
    
    func isOnboardingCompleted() async -> Bool {
        await withCheckedContinuation { [weak self] continuation in
            self?.continuation = continuation
        }
    }
}

extension OnboardingHandler: OnboardingViewControllerDelegate {
    
    func dismissButtonPressed() {
        continuation?.resume(returning: true)
    }
}
