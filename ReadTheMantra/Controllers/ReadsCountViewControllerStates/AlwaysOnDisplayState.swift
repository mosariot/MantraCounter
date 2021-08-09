//
//  AlwaysOnDisplayState.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 04.08.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

final class AlwaysOnDisplayState: ReadsCountViewControllerState {
    
    private let lightHapticGenerator = UIImpactFeedbackGenerator(style: .light)
    
    override func apply() {
        lightHapticGenerator.prepare()
        UIApplication.shared.isIdleTimerDisabled = true
        context?.readsCountView.displayAlwaysOn.setImage(UIImage(systemName: "sun.max.fill"), for: .normal)
        context?.readsCountView.addReadsButton.isEnabled = false
        context?.readsCountView.addRoundsButton.isEnabled = false
        context?.readsCountView.setProperValueButton.isEnabled = false
        context?.readsCountView.readsGoalButton.isEnabled = false
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapped))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        singleTap.numberOfTapsRequired = 1
        doubleTap.numberOfTapsRequired = 2
        context?.readsCountView.addGestureRecognizer(singleTap)
        context?.readsCountView.addGestureRecognizer(doubleTap)
        singleTap.require(toFail: doubleTap)
    }
    
    @objc private func singleTapped() {
        lightHapticGenerator.impactOccurred()
        adjustMantra(with: 1, adjustingType: .reads, animated: false)
        flashScreen()
    }
    
    @objc private func doubleTapped() {
        lightHapticGenerator.impactOccurred()
        adjustMantra(with: 1, adjustingType: .rounds)
    }
    
    private func flashScreen() {
        guard let context = context else { return }
        let dimmedView = UIView(frame: context.view.bounds)
        dimmedView.backgroundColor = .systemGray5
        dimmedView.alpha = 0.6
        context.view.addSubview(dimmedView)
        UIView.animate(withDuration: 0.15) {
            dimmedView.alpha = 0.0
        } completion: { _ in
            dimmedView.removeFromSuperview()
        }
    }
}
