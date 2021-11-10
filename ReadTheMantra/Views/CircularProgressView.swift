//
//  CircularProgressView.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 11.09.2020.
//  Copyright © 2018 Yogesh Manghnani. All rights reserved.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

final class CircularProgressView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    //MARK: - Public
    
    override var bounds: CGRect {
        didSet {
            setupView()
            if currentGoal != goal {
                setNewGoal(to: currentGoal)
            } else {
                setValueCircleAnimation(to: updatedValue, animated: false)
            }
            setNewValueLabel(to: updatedValue, animated: false)
        }
    }
    
    var value = 0 {
        didSet { updatedValue = value }
    }
    
    @NotNegative var currentSessionValue = 0
    
    var goal = Constants.initialReadsGoal {
        didSet { currentGoal = goal }
    }
    
    var isAlwayOnDisplay = false {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.label.center = self.labelCenter
            }
            if isAlwayOnDisplay {
                currentSessionLabelAnimateIn()
            } else {
                currentSessionLabelAnimateOut()
            }
        }
    }
    
    private func currentSessionLabelAnimateIn() {
        self.currentSessionLabel.isHidden = false
        self.currentSessionLabel.alpha = 0
        self.currentSessionLabel.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.currentSessionLabel.alpha = 1
            self.currentSessionLabel.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    private func currentSessionLabelAnimateOut() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: []) {
            self.currentSessionLabel.alpha = 0
            self.currentSessionLabel.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        } completion: { _ in
            self.currentSessionLabel.isHidden = true
        }
    }
    
    func setNewGoal(to newGoal: Int, animated: Bool = true) {
        
        currentGoal = newGoal
        
        var currentProgress: Double {
            let progressConstant = Double(value) / Double(goal)
            if progressConstant > 1 { return 1 }
            else if progressConstant < 0 { return 0 }
            else { return progressConstant }
        }
        
        var newProgress: Double {
            let progressConstant = Double(value) / Double(newGoal)
            if progressConstant > 1 { return 1 }
            else if progressConstant < 0 { return 0 }
            else { return progressConstant }
        }
        
        foregroundLayer.strokeEnd = CGFloat(newProgress)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = currentProgress
        animation.toValue = newProgress
        animation.duration = animated ? Constants.progressAnimationDuration : 0
        foregroundLayer.add(animation, forKey: "foregroundAnimation")
        
        guard animated else {
            self.setForegroundLayerColor(value: value, readsGoal: goal)
            return
        }
        
        var currentTime: Double = 0
        let currentReadsGoal = goal
        goalCircleTimer = Timer.scheduledTimer(withTimeInterval: Constants.progressAnimationDuration * 0.01, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if currentTime >= Constants.progressAnimationDuration * (Constants.progressAnimationDuration + 0.01) {
                timer.invalidate()
                self.goalCircleTimer = nil
                self.goal = newGoal
            } else {
                let momentGoal = Double(currentReadsGoal) + Double(newGoal - currentReadsGoal) * (currentTime / Constants.progressAnimationDuration)
                currentTime += Constants.progressAnimationDuration * 0.01
                self.setForegroundLayerColor(value: self.value, readsGoal: Int(momentGoal))
            }
        }
        goalCircleTimer?.fire()
    }
    
    func setNewValue(to newValue: Int, animated: Bool = true) {
        setValueCircleAnimation(to: newValue, animated: animated)
        setNewValueLabel(to: newValue, animated: animated)
    }
    
    func stopAnimationIfNeeded() {
            labelTimer?.invalidate()
            labelTimer = nil
            goalCircleTimer?.invalidate()
            goalCircleTimer = nil
    }
    
    //MARK: - Private
    
    private var updatedValue = 0
    private var currentGoal = Constants.initialReadsGoal
    private let label = CopyableLabel()
    private let currentSessionLabel = UILabel()
    private var labelCenter: CGPoint { CGPoint(x: pathCenter.x, y: pathCenter.y - (isAlwayOnDisplay ? radius / 3 : 0)) }
    private let lineWidth: CGFloat = 7
    private let foregroundLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    private var pathCenter: CGPoint { convert(center, from: superview) }
    private var radius: CGFloat { (([bounds.width, bounds.height].min() ?? lineWidth) - lineWidth) / 2 }
    private var labelTimer: Timer?
    private var goalCircleTimer: Timer?
    
    private func setValueCircleAnimation(to newValue: Int, animated: Bool) {
        
        updatedValue = newValue
        
        var progress: Double {
            let progressConstant = Double(newValue) / Double(goal)
            if progressConstant > 1 { return 1 }
            else if progressConstant < 0 { return 0 }
            else { return progressConstant }
        }
        
        foregroundLayer.strokeEnd = CGFloat(progress)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = Double(value) / Double(goal)
        animation.toValue = progress
        animation.duration = animated ? Constants.progressAnimationDuration : 0
        foregroundLayer.add(animation, forKey: "foregroundAnimation")
    }
    
    private func setNewValueLabel(to newValue: Int, animated: Bool) {
        
        currentSessionValue += newValue - value
        
        guard animated else {
            value = newValue
            self.label.text = value.formattedNumber()
            self.setForegroundLayerColor(value: value, readsGoal: goal)
            let fontSize = self.labelFontSize(for: value)
            self.setLabel(withSize: fontSize)
            self.setCurrentSessionLabel()
            return
        }
        
        updatedValue = newValue
        var currentTime: Double = 0
        labelTimer = Timer.scheduledTimer(withTimeInterval: Constants.progressAnimationDuration * 0.01, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if currentTime >= Constants.progressAnimationDuration * (Constants.progressAnimationDuration + 0.01) {
                timer.invalidate()
                self.labelTimer = nil
                self.value = newValue
                self.setCurrentSessionLabel()
            } else {
                var momentValue = Double(self.value) + Double(newValue - self.value) * (currentTime / Constants.progressAnimationDuration)
                currentTime += Constants.progressAnimationDuration * 0.01
                momentValue.round(.toNearestOrAwayFromZero)
                self.label.text = Int(momentValue).formattedNumber()
                self.setForegroundLayerColor(value: Int(momentValue), readsGoal: self.goal)
                let fontSize = self.labelFontSize(for: Int(momentValue))
                self.setLabel(withSize: fontSize)
            }
        }
        labelTimer?.fire()
    }
    
    private func setupView() {
        makeBar()
        addSubview(label)
        addSubview(currentSessionLabel)
    }
    
    private func makeBar() {
        drawBackgroundLayer()
        drawForegroundLayer()
    }
    
    private func drawBackgroundLayer() {
        
        let path = UIBezierPath(arcCenter: pathCenter, radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        backgroundLayer.path = path.cgPath
        backgroundLayer.strokeColor = UIColor.systemGray.cgColor
        backgroundLayer.lineWidth = lineWidth - (0.3 * lineWidth)
        backgroundLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(backgroundLayer)
    }
    
    private func drawForegroundLayer() {
        
        let startAngle = (-CGFloat.pi / 2)
        let endAngle = 2 * CGFloat.pi + startAngle
        
        let path = UIBezierPath(arcCenter: pathCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        foregroundLayer.lineCap = .round
        foregroundLayer.path = path.cgPath
        foregroundLayer.lineWidth = lineWidth
        foregroundLayer.fillColor = UIColor.clear.cgColor
        foregroundLayer.strokeColor = UIColor.systemGreen.cgColor
        foregroundLayer.strokeEnd = 0
        
        layer.addSublayer(foregroundLayer)
    }
    
    private func labelFontSize(for value: Int) -> CGFloat {
        if value >= 1_000_000 {
            return 34
        } else if value >= 100_000 {
            return 39
        } else {
            return 44
        }
    }
    
    private func setLabel(withSize fontSize: CGFloat) {
        label.font = .rounded(ofSize: fontSize, weight: .medium)
        label.sizeToFit()
        label.center = labelCenter
    }
    
    private func setCurrentSessionLabel() {
        let fontSize = self.labelFontSize(for: value)
        currentSessionLabel.font = .rounded(ofSize: fontSize, weight: .medium)
        currentSessionLabel.textColor = Constants.accentColor ?? .systemOrange
        currentSessionLabel.text = currentSessionValue.formattedNumber()
        currentSessionLabel.sizeToFit()
        currentSessionLabel.center = CGPoint(x: pathCenter.x, y: pathCenter.y + radius / 3)
    }
    
    private func setForegroundLayerColor(value: Int, readsGoal: Int) {
        var color = UIColor()
        switch value {
        case 0 ..< readsGoal / 2:
            color = .systemGreen
        case readsGoal / 2 ..< readsGoal:
            color = .systemOrange
        case readsGoal...:
            color = .systemPurple
        default:
            break
        }
        foregroundLayer.strokeColor = color.cgColor
    }
}
