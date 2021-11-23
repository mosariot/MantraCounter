//
//  DisplaySystemBehaviorState.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 04.08.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

final class DisplaySystemBehaviorState: ReadsCountViewControllerState {
    
    private let mediumHapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    override func handleAdjustMantraCount(adjustingType: AdjustingType) {
        showUpdatingAlert(adjustingType: adjustingType)
    }
    
    private func showUpdatingAlert(adjustingType: AdjustingType) {
        guard let mantra = context?.mantra, let context = context else { return }
        let alert = AlertControllerFactory.updatingAlert(mantra: mantra, updatingType: adjustingType, delegate: context) { [weak self] value in
            guard let self = self else { return }
            self.mediumHapticGenerator.impactOccurred()
            self.adjustMantra(with: value, adjustingType: adjustingType)
        }
        context.present(alert, animated: true, completion: nil)
    }
    
    override func apply() {
        guard let context = context else { return }
        mediumHapticGenerator.prepare()
        animateView(context)
        adjustReadsCountView(context)
        setupTaps(context)
    }
    
    private func animateView(_ context: ReadsCountStateContext) {
        UIApplication.shared.isIdleTimerDisabled = false
        UIView.animate(withDuration: 0.3) {
            context.readsCountView.backgroundColor = .systemBackground
            context.readsCountView.circularProgressView.backgroundColor = .systemBackground
        }
    }
    
    private func adjustReadsCountView(_ context: ReadsCountStateContext) {
        context.readsCountView.displayAlwaysOn.setImage(UIImage(systemName: "sun.max"), for: .normal)
        context.readsCountView.addReadsButton.isEnabled = true
        context.readsCountView.addRoundsButton.isEnabled = true
        context.readsCountView.setProperValueButton.isEnabled = true
        context.readsCountView.readsGoalButton.isEnabled = true
        context.readsCountView.circularProgressView.isAlwayOnDisplay = false
    }
    
    private func setupTaps(_ context: ReadsCountStateContext) {
        context.readsCountView.gestureRecognizers?.forEach(context.readsCountView.removeGestureRecognizer)
    }
}
