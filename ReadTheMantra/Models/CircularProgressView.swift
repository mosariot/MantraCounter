//
//  CircularProgressView.swift
//  ReadTheMantra
//
//  Created by Александр Воробьев on 11.09.2020.
//  Copyright © 2020 Александр Воробьев. All rights reserved.
//

import UIKit

class CircularProgressView: UIView {
    
    //MARK: - awakeFromNib
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
        label.text = "/(currentValue)"
        label.font = UIFont.boldSystemFont(ofSize: 30)
    }
    
    //MARK: - Public
    
    public var currentValue = 0
    public var readsGoal = 100_000
    
    public func setValue(to newValue: Int) {
        
        var progress: Double {
            let progressConstant = Double(newValue) / Double(readsGoal)
            if progressConstant > 1 { return 1 }
            else if progressConstant < 0 { return 0 }
            else { return progressConstant }
        }
        
        foregroundLayer.strokeEnd = CGFloat(progress)
        
        // circle animation
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = Double(currentValue) / Double(readsGoal)
        animation.toValue = progress
        animation.duration = 1
        foregroundLayer.add(animation, forKey: "foregroundAnimation")
        
        // number animation
        var currentTime: Double = 0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] (timer) in
            if currentTime >= 1.01 {
                timer.invalidate()
                self?.currentValue = newValue
            } else {
                let momentValue = Double(self?.currentValue ?? 0) + Double(newValue - (self?.currentValue ?? 0)) * currentTime
                currentTime += 0.01
                self?.label.text = Int(momentValue).stringFormattedWithSpaces()
                self?.setForegroundLayerColor(value: Int(momentValue))
                self?.setlabelFont(for: Int(momentValue))
            }
        }
        timer.fire()
    }
    
    //MARK: - Private
    
    private let label = UILabel()
    private let lineWidth: CGFloat = 5
    private let foregroundLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    private var pathCenter: CGPoint {
        convert(center, from: superview)
    }
    private var radius: CGFloat {
        if self.frame.width < self.frame.height {
            return (frame.width - lineWidth)/2
        } else {
            return (frame.height - lineWidth)/2 }
    }
    
    private func setupView() {
        makeBar()
        addSubview(label)
    }

    private func makeBar() {
        layer.sublayers = nil
        drawBackgroundLayer()
        drawForegroundLayer()
    }
    
    private func drawBackgroundLayer() {
        
        let path = UIBezierPath(arcCenter: pathCenter, radius: self.radius, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        self.backgroundLayer.path = path.cgPath
        self.backgroundLayer.strokeColor = UIColor.systemGray.cgColor
        self.backgroundLayer.lineWidth = lineWidth - (0.2 * lineWidth)
        self.backgroundLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(backgroundLayer)
    }
    
    private func drawForegroundLayer() {
        
        let startAngle = (-CGFloat.pi/2)
        let endAngle = 2 * CGFloat.pi + startAngle
        
        let path = UIBezierPath(arcCenter: pathCenter, radius: self.radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        foregroundLayer.lineCap = CAShapeLayerLineCap.round
        foregroundLayer.path = path.cgPath
        foregroundLayer.lineWidth = lineWidth
        foregroundLayer.fillColor = UIColor.clear.cgColor
        foregroundLayer.strokeColor = UIColor.systemBlue.cgColor
        foregroundLayer.strokeEnd = 0
        
        layer.addSublayer(foregroundLayer)
    }
        
    private func setlabelFont(for value: Int) {
        var font = UIFont.boldSystemFont(ofSize: 30)
        switch value {
        case 1_000_000...:
            font = UIFont.systemFont(ofSize: 30, weight: .medium)
        case 100_000...:
            font = UIFont.systemFont(ofSize: 35, weight: .medium)
        default:
            font = UIFont.systemFont(ofSize: 40, weight: .medium)
        }
        label.font = font
        label.sizeToFit()
        label.center = pathCenter
    }
    
    private func setForegroundLayerColor(value: Int) {
        var color = UIColor()
        switch value {
        case 0...readsGoal/2:
            color = UIColor.systemBlue
        case readsGoal/2...readsGoal-1:
            color = UIColor.systemOrange
        case readsGoal...:
            color = UIColor.systemPurple
        default:
            break
        }
        foregroundLayer.strokeColor = color.cgColor
    }
}
