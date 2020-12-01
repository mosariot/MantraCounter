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
    
    //MARK: - awakeFromNib
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
    }
    
    //MARK: - Public
    
    override var bounds: CGRect {
        didSet {
            setupView()
            if currentReadsGoal != readsGoal {
                setGoalCircleAnimation(to: currentReadsGoal)
            } else {
                setValueCircleAnimation(to: currentValue)
            }
            setValueLabelAnimation(to: currentValue)
        }
    }
    
    public var value = 0
    public var currentValue = 0
    public var readsGoal = Constants.initialReadsGoal
    public var currentReadsGoal = Constants.initialReadsGoal
    
    public func setGoalCircleAnimation(to newGoal: Int) {
        
        var currentProgress: Double {
            let progressConstant = Double(value) / Double(readsGoal)
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
        animation.duration = Constants.progressAnimationDuration
        foregroundLayer.add(animation, forKey: "foregroundAnimation")
        
        var currentTime: Double = 0
        let currentReadsGoal = readsGoal
        let timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] (timer) in
            if currentTime >= Constants.progressAnimationDuration + 0.01 {
                timer.invalidate()
                self?.readsGoal = newGoal
            } else {
                let momentGoal = Double(currentReadsGoal) + Double(newGoal - currentReadsGoal) * currentTime
                currentTime += 0.01
                self?.setForegroundLayerColor(value: Int(self?.value ?? 0), readsGoal: Int(momentGoal))
            }
        }
        timer.fire()
    }
    
    public func setValueCircleAnimation(to newValue: Int) {
        
        var progress: Double {
            let progressConstant = Double(newValue) / Double(readsGoal)
            if progressConstant > 1 { return 1 }
            else if progressConstant < 0 { return 0 }
            else { return progressConstant }
        }
        
        foregroundLayer.strokeEnd = CGFloat(progress)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = Double(value) / Double(readsGoal)
        animation.toValue = progress
        animation.duration = Constants.progressAnimationDuration
        foregroundLayer.add(animation, forKey: "foregroundAnimation")
    }
    
    public func setValueLabelAnimation(to newValue: Int) {
        var currentTime: Double = 0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] (timer) in
            if currentTime >= Constants.progressAnimationDuration + 0.01 {
                timer.invalidate()
                self?.value = newValue
            } else {
                var momentValue = Double(self?.value ?? 0) + Double(newValue - (self?.value ?? 0)) * currentTime
                currentTime += 0.01
                momentValue.round(.toNearestOrAwayFromZero)
                self?.label.text = Int(momentValue).stringFormattedWithSpaces()
                self?.setForegroundLayerColor(value: Int(momentValue), readsGoal: self?.readsGoal ?? Constants.initialReadsGoal)
                if let fontSize = self?.labelFontSize(for: Int(momentValue)) {
                    self?.setLabel(withSize: fontSize)
                }
            }
        }
        timer.fire()
    }
    
    //MARK: - Private
    
    private let label = UILabel()
    private let lineWidth: CGFloat = 7
    private let foregroundLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    private var pathCenter: CGPoint {
        convert(center, from: superview)
    }
    private var radius: CGFloat {
        if frame.width < frame.height {
            return (frame.width - lineWidth)/2
        } else {
            return (frame.height - lineWidth)/2 }
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
        
        foregroundLayer.lineCap = CAShapeLayerLineCap.round
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
            color = UIColor.systemGreen
        case readsGoal/2..<readsGoal:
            color = UIColor.systemOrange
        case readsGoal...:
            color = UIColor.systemPurple
        default:
            break
        }
        foregroundLayer.strokeColor = color.cgColor
    }
}
