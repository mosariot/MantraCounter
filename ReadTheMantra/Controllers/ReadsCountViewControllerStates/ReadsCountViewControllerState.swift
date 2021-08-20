//
//  ReadsCountViewControllerState.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 04.08.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

protocol ReadsCountStateContext: UIViewController, UITextFieldDelegate {
    var mantra: Mantra? { get }
    var readsCountView: ReadsCountView! { get }
    var confettiView: ConfettiView { get set }
    var previousReadsCount: Int32? { get set }
    var shouldInvalidatePreviousState: Bool { get set }
}

class ReadsCountViewControllerState {
    
    private var mantraDataManager: DataManager = MantraDataManager()
    private let congratulationsGenerator = UINotificationFeedbackGenerator()
    weak var context: ReadsCountStateContext?
    
    init(context: ReadsCountStateContext) {
        self.context = context
        congratulationsGenerator.prepare()
    }
    
    func handleAdjustMantraCount(adjustingType: AdjustingType) { }
    func apply() { }
}

// MARK: - Common AdjustMantra Implementation

extension ReadsCountViewControllerState {
    
    func adjustMantra(with value: Int32, adjustingType: AdjustingType, animated: Bool = true) {
        guard let mantra = context?.mantra else { return }
        let oldReads = mantra.reads
        mantraDataManager.updateMantraValues(mantra, with: value, and: adjustingType)
        updateProrgessView(for: adjustingType, animated: animated)
        context?.readsCountView.readsGoalButton.setTitle(NSLocalizedString("Goal: ",
                                                   comment: "Button on ReadsCountViewController") + Int(mantra.readsGoal).formattedNumber(),
                                 for: .normal)
        if adjustingType != .goal {
            context?.previousReadsCount = oldReads
            readsCongratulationsCheck(oldReads: context?.previousReadsCount, newReads: mantra.reads)
        }
    }
    
    private func updateProrgessView(for updatingType: AdjustingType, animated: Bool) {
        guard let mantra = context?.mantra else { return }
        switch updatingType {
        case .goal:
            context?.readsCountView.circularProgressView.setNewGoal(to: Int(mantra.readsGoal), animated: animated)
        case .reads, .rounds, .properValue:
            context?.readsCountView.circularProgressView.setNewValue(to: Int(mantra.reads), animated: animated)
        }
    }
    
    private func readsCongratulationsCheck(oldReads: Int32?, newReads: Int32) {
        guard let mantra = context?.mantra, let oldReads = oldReads, let context = context else { return }
        context.shouldInvalidatePreviousState = false
        if (oldReads < mantra.readsGoal/2 && mantra.readsGoal/2..<mantra.readsGoal ~= newReads) {
            afterDelay(Constants.progressAnimationDuration + 0.3) {
                if !context.shouldInvalidatePreviousState {
                    self.showReadsCongratulationsAlert(level: .halfGoal)
                }
            }
        }
        
        if oldReads < mantra.readsGoal && newReads >= mantra.readsGoal {
            congratulationsGenerator.notificationOccurred(.success)
            context.confettiView = ConfettiView.makeView(inView: context.splitViewController?.view ?? context.view, animated: true)
            context.confettiView.startConfetti()
            
            afterDelay(Constants.progressAnimationDuration + 1.8) {
                if !context.shouldInvalidatePreviousState {
                    self.showReadsCongratulationsAlert(level: .fullGoal)
                }
            }
        }
    }
    
    private func showReadsCongratulationsAlert(level: Level) {
        let alert = UIAlertController.congratulationsAlert(level: level)
        context?.present(alert, animated: true, completion: nil)
    }
}
