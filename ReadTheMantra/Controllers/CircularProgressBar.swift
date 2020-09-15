//
//  CircularProgressBar.swift
//  ReadTheMantra
//
//  Created by Александр Воробьев on 11.09.2020.
//  Copyright © 2020 Александр Воробьев. All rights reserved.
//

import UIKit

class CircularProgressBar: UIView {
    
    //MARK: - awakeFromNib
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
        label.text = "0"
    }
    
    
    //MARK: - Public
    
    public var currentValue = 0
    public var lineWidth: CGFloat = 8 {
        didSet {
            foregroundLayer.lineWidth = lineWidth
            backgroundLayer.lineWidth = lineWidth - (0.2 * lineWidth)
        }
    }
    public var labelFont: UIFont = .systemFont(ofSize: 35) {
        didSet {
            label.font = labelFont
            label.sizeToFit()
            configLabel()
        }
    }
    
    public func setValue(to value: Int) {
        
        var progress: Double {
            let progressConstant = Double(value) / Double(100_000)
            if progressConstant > 1 { return 1 }
            else if progressConstant < 0 { return 0 }
            else { return progressConstant }
        }
        
        foregroundLayer.strokeEnd = CGFloat(progress)
        
        // circle animation
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = Double(currentValue) / Double(100_000)
        animation.toValue = progress
        animation.duration = 1
        foregroundLayer.add(animation, forKey: "foregroundAnimation")
        
        //number animation
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.numberStyle = .decimal
        
        var currentTime: Double = 0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { (timer) in
            if currentTime >= 1.05 {
                timer.invalidate()
                self.currentValue = value
            } else {
                let momentReads = Double(self.currentValue) + Double(value - self.currentValue) * currentTime
                currentTime += 0.05
                let formattedReads = formatter.string(from: NSNumber(value: Int(momentReads.rounded())))
                self.label.text = formattedReads
                self.setForegroundLayerColor(reads: Int(momentReads))
                self.configLabel()
            }
        }
        timer.fire()
    }
    
    //MARK: - Private
    
    private var label = UILabel()
    private let foregroundLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    private var radius: CGFloat {
        if self.frame.width < self.frame.height {
            return (frame.width - lineWidth)/2
        } else {
            return (frame.height - lineWidth)/2 }
    }
    
    private var pathCenter: CGPoint {
        convert(center, from: superview)
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
    
    private func setForegroundLayerColor(reads: Int) {
        var color = UIColor()
        switch reads {
        case 0...39_999:
            color = UIColor.systemBlue
        case 40_000...99_999:
            color = UIColor.systemOrange
        case 100_000...:
            color = UIColor.systemPurple
        default:
            break
        }
        foregroundLayer.strokeColor = color.cgColor
    }
    
    private func configLabel() {
        label.sizeToFit()
        label.center = pathCenter
    }
    
    private func setupView() {
        makeBar()
        addSubview(label)
    }
}
