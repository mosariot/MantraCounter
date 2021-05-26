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
                setGoalAnimation(to: currentGoal)
            } else {
                setValueCircleAnimation(to: currentValue, animated: false)
            }
            setValueLabelAnimation(to: currentValue, animated: false)
        }
    }
    
    var value = 0 {
        didSet { currentValue = value }
    }
    
    var goal = Constants.initialReadsGoal {
        didSet { currentGoal = goal }
    }
    
    func setGoalAnimation(to newGoal: Int, animated: Bool = true) {
        
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
        goalCircleTimer = Timer.scheduledTimer(withTimeInterval: Constants.progressAnimationDuration*0.01, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if currentTime >= Constants.progressAnimationDuration*1.01 {
                timer.invalidate()
                self.goalCircleTimer = nil
                self.goal = newGoal
            } else {
                let momentGoal = Double(currentReadsGoal) + Double(newGoal - currentReadsGoal) * (currentTime / Constants.progressAnimationDuration)
                currentTime += Constants.progressAnimationDuration*0.01
                self.setForegroundLayerColor(value: self.value, readsGoal: Int(momentGoal))
            }
        }
        goalCircleTimer?.fire()
    }
    
    func setValueAnimation(to newValue: Int, animated: Bool = true) {
        setValueCircleAnimation(to: newValue, animated: animated)
        setValueLabelAnimation(to: newValue, animated: animated)
    }
    
    func stopAnimationIfNeeded() {
            labelTimer?.invalidate()
            labelTimer = nil
            goalCircleTimer?.invalidate()
            goalCircleTimer = nil
    }
    
    //MARK: - Private
    
    private var currentValue = 0
    private var currentGoal = Constants.initialReadsGoal
    private let label = CopyableLabel()
    private let lineWidth: CGFloat = 7
    private let foregroundLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    private var pathCenter: CGPoint {
        convert(center, from: superview)
    }
    private var radius: CGFloat {
        (([bounds.width, bounds.height].min() ?? lineWidth) - lineWidth) / 2
    }
    private var labelTimer: Timer?
    private var goalCircleTimer: Timer?
    
    private func setValueCircleAnimation(to newValue: Int, animated: Bool) {
        
        currentValue = newValue
        
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
    
    private func setValueLabelAnimation(to newValue: Int, animated: Bool) {
        
        guard animated else {
            self.label.text = value.formattedNumber()
            self.setForegroundLayerColor(value: value, readsGoal: goal)
            let fontSize = self.labelFontSize(for: value)
            self.setLabel(withSize: fontSize)
            return
        }
        
        currentValue = newValue
        var currentTime: Double = 0
        labelTimer = Timer.scheduledTimer(withTimeInterval: Constants.progressAnimationDuration*0.01, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if currentTime >= Constants.progressAnimationDuration*1.01 {
                timer.invalidate()
                self.labelTimer = nil
                self.value = newValue
            } else {
                var momentValue = Double(self.value) + Double(newValue - self.value) * (currentTime / Constants.progressAnimationDuration)
                currentTime += Constants.progressAnimationDuration*0.01
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
    }
    
    private func makeBar() {
        drawBackgroundLayer()
        drawForegroundLayer()
    }
    
    private func drawBackgroundLayer() {
        
        let path = UIBezierPath(arcCenter: pathCenter, radius: radius, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        backgroundLayer.path = path.cgPath
        backgroundLayer.strokeColor = UIColor.systemGray.cgColor
        backgroundLayer.lineWidth = lineWidth - (0.3 * lineWidth)
        backgroundLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(backgroundLayer)
    }
    
    private func drawForegroundLayer() {
        
        let startAngle = (-CGFloat.pi/2)
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
        label.center = pathCenter
    }
    
    private func setForegroundLayerColor(value: Int, readsGoal: Int) {
        var color = UIColor()
        switch value {
        case 0..<readsGoal/2:
            color = .systemGreen
        case readsGoal/2..<readsGoal:
            color = .systemOrange
        case readsGoal...:
            color = .systemPurple
        default:
            break
        }
        foregroundLayer.strokeColor = color.cgColor
    }
}
