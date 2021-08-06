//
//  AlwaysOnDisplayState.swift
//  ReadTheMantra
//
//  Created by Александр Воробьев on 04.08.2021.
//  Copyright © 2021 Александр Воробьев. All rights reserved.
//

import UIKit

class AlwaysOnDisplayState: ReadsCountViewControllerState {
    
    private weak var context: ReadsCountViewController?
    private let lightHapticGenerator = UIImpactFeedbackGenerator(style: .light)
    
    func apply(to context: ReadsCountViewController) {
        self.context = context
        lightHapticGenerator.prepare()
        UIApplication.shared.isIdleTimerDisabled = true
        context.readsCountView.displayAlwaysOn.setImage(UIImage(systemName: "sun.max.fill"), for: .normal)
        context.readsCountView.addReadsButton.isEnabled = false
        context.readsCountView.addRoundsButton.isEnabled = false
        context.readsCountView.setProperValueButton.isEnabled = false
        context.readsCountView.readsGoalButton.isEnabled = false
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapped))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        singleTap.numberOfTapsRequired = 1
        doubleTap.numberOfTapsRequired = 2
        context.readsCountView.addGestureRecognizer(singleTap)
        context.readsCountView.addGestureRecognizer(doubleTap)
        singleTap.require(toFail: doubleTap)
    }
    
    @objc private func singleTapped() {
        lightHapticGenerator.impactOccurred()
        context?.adjustMantra(with: 1, updatingType: .reads, animated: false)
        flashScreen()
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
    
    @objc private func doubleTapped() {
        context?.adjustMantra(with: 1, updatingType: .rounds)
    }
}
