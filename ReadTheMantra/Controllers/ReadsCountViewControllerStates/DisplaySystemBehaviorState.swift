//
//  DisplaySystemBehaviorState.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 04.08.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

class DisplaySystemBehaviorState: ReadsCountViewControllerState {
    
    func apply(to context: ReadsCountViewController) {
        UIApplication.shared.isIdleTimerDisabled = false
        context.readsCountView.displayAlwaysOn.setImage(UIImage(systemName: "sun.max"), for: .normal)
        context.readsCountView.addReadsButton.isEnabled = true
        context.readsCountView.addRoundsButton.isEnabled = true
        context.readsCountView.setProperValueButton.isEnabled = true
        context.readsCountView.readsGoalButton.isEnabled = true
        context.readsCountView.gestureRecognizers?.forEach(context.readsCountView.removeGestureRecognizer)
    }
}
