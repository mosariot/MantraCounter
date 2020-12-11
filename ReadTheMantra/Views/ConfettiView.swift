//
//  ConfettiView.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 19.11.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.

import UIKit

final class ConfettiView: UIView {
    
    private var confettiEmitter = CAEmitterLayer()
    
    public func startConfetti() {
        makeConfettiEmitter()
        layer.addSublayer(confettiEmitter)
        
        alpha = 0
        UIView.animate(withDuration: 0.6) {
            self.alpha = 1
        } completion: { (_) in
            self.stopConfetti()
        }
    }
    
    private func makeConfettiEmitter() {
        confettiEmitter.emitterPosition = CGPoint(x: frame.size.width / 2.0, y: 0)
        confettiEmitter.emitterShape = .line
        confettiEmitter.emitterSize = CGSize(width: frame.size.width, height: 1)
        
        var cells = [CAEmitterCell]()
        
        let colors = [UIColor(red: 149/255, green: 58/255, blue: 255/255, alpha: 1),
                      UIColor(red: 255/255, green: 195/255, blue: 41/255, alpha: 1),
                      UIColor(red: 255/255, green: 101/255, blue: 26/255, alpha: 1),
                      UIColor(red: 123/255, green: 92/255, blue: 255/255, alpha: 1),
                      UIColor(red: 76/255, green: 126/255, blue: 255/255, alpha: 1),
                      UIColor(red: 71/255, green: 192/255, blue: 255/255, alpha: 1),
                      UIColor(red: 255/255, green: 47/255, blue: 39/255, alpha: 1),
                      UIColor(red: 255/255, green: 91/255, blue: 134/255, alpha: 1),
                      UIColor(red: 233/255, green: 122/255, blue: 208/255, alpha: 1)]
        
        for color in colors {
            cells.append(confettiWithColor(color: color))
        }
        
        confettiEmitter.emitterCells = cells
    }
    
    private func confettiWithColor(color: UIColor) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 7
        cell.lifetime = 10
        cell.lifetimeRange = 0
        cell.color = color.cgColor
        cell.velocity = 250
        cell.velocityRange = 50
        cell.emissionLongitude = CGFloat.pi
        cell.emissionRange = CGFloat.pi / 4
        cell.spin = 4
        cell.spinRange = 8
        cell.scaleRange = 0.5
        cell.scaleSpeed = -0.05
        cell.contents = UIImage(named: "confetti")?.cgImage
        return cell
    }
    
    private func stopConfetti() {
        var currentTime: Float = 0
        let currentBirthRate = confettiEmitter.birthRate
        let stopTime: Float = 1.2
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] (timer) in
            guard let self = self else { return }
            if currentTime >= stopTime + 0.1 {
                timer.invalidate()
            } else {
                self.confettiEmitter.birthRate = currentBirthRate * (stopTime - currentTime)
                currentTime += 0.1
            }
        }
        timer.fire()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Constants.progressAnimationDuration + 2.7) {
            self.removeFromSuperview()
        }
    }
}
