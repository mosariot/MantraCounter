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
        guard let context = context else { return }
        lightHapticGenerator.prepare()
        animateView(context)
        showHudView(context)
        adjustReadsCountView(context)
        setupTaps(context)
    }
    
    private func showHudView(_ context: ReadsCountStateContext) {
        guard !UserDefaults.standard.bool(forKey: "isFirstSwitchDisplayMode") else {
            UserDefaults.standard.setValue(false, forKey: "isFirstSwitchDisplayMode")
            return
        }
        let attachment1 = NSTextAttachment()
        attachment1.image = UIImage(systemName: "hand.tap")?.withTintColor(.white)
        let attachment2 = NSTextAttachment()
        attachment2.image = UIImage(systemName: "plus.circle")?.withTintColor(.white)
        let attachment3 = NSTextAttachment()
        attachment3.image = UIImage(systemName: "goforward")?.withTintColor(.white)
        let imageString = NSMutableAttributedString()
        let tapString = NSMutableAttributedString(attachment: attachment1)
        let plusString = NSMutableAttributedString(attachment: attachment2)
        let goforwardString = NSMutableAttributedString(attachment: attachment3)
        let equalString = NSAttributedString(string: "  =  ")
        let newLineString = NSAttributedString(string: "\n")
        let spaceString = NSAttributedString(string: " ")
        imageString.append(tapString)
        imageString.append(equalString)
        imageString.append(plusString)
        imageString.append(newLineString)
        imageString.append(tapString)
        imageString.append(spaceString)
        imageString.append(tapString)
        imageString.append(equalString)
        imageString.append(goforwardString)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 12
        paragraphStyle.alignment = .center
        imageString.addAttribute(
            NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, imageString.length))
        
        let hudView = HudView.makeViewWithoutCheckmark(inView: context.view, withText: imageString)
        hudView.hide(afterDelay: 1.2) { [weak context] in
            context?.view.isUserInteractionEnabled = true
        }
    }
    
    private func adjustReadsCountView(_ context: ReadsCountStateContext) {
        context.readsCountView.displayAlwaysOn.setImage(UIImage(systemName: "sun.max.fill"), for: .normal)
        context.readsCountView.addReadsButton.isEnabled = false
        context.readsCountView.addRoundsButton.isEnabled = false
        context.readsCountView.setProperValueButton.isEnabled = false
        context.readsCountView.readsGoalButton.isEnabled = false
        context.readsCountView.circularProgressView.isAlwayOnDisplay = true
    }
    
    private func animateView(_ context: ReadsCountStateContext) {
        UIApplication.shared.isIdleTimerDisabled = true
        UIView.animate(withDuration: 0.3) {
            context.readsCountView.backgroundColor = .systemGray5
            context.readsCountView.circularProgressView.backgroundColor = .systemGray5
        }
    }
    
    private func setupTaps(_ context: ReadsCountStateContext) {
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
