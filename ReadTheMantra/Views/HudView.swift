//
//  HudView.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 16.04.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

final class HudView: UIView {
    
    private static var withCheckmark = true
    private static var text = ""
    private static var attributedText: NSMutableAttributedString = NSMutableAttributedString()
    
    //MARK: - Convenient initializer
    
    @discardableResult
    static func makeViewWithCheckmark(
        inView view: UIView, withText text: String, blockViewInteractions: Bool = true) -> HudView {
            let hudView = HudView(frame: view.bounds)
            Self.text = text
            Self.withCheckmark = true
            hudView.isOpaque = false
            view.addSubview(hudView)
            view.isUserInteractionEnabled = !blockViewInteractions
            hudView.show()
            return hudView
        }
    
    @discardableResult
    static func makeViewWithoutCheckmark(
        inView view: UIView,
        withText text: NSMutableAttributedString,
        blockViewInteractions: Bool = true) -> HudView {
            let hudView = HudView(frame: view.bounds)
            self.attributedText = text
            Self.withCheckmark = false
            hudView.isOpaque = false
            view.addSubview(hudView)
            view.isUserInteractionEnabled = !blockViewInteractions
            hudView.show()
            return hudView
        }
    
    //MARK: - Draw the HUD View
    
    override func draw(_ rect: CGRect) {
        let boxWidth = 96.0
        let boxHeight = 96.0
        
        let boxRect = CGRect(
            x: round((bounds.width - boxWidth)/2),
            y: round((bounds.height - boxHeight)/2),
            width: boxWidth,
            height: boxHeight)
        
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor.systemGray.withAlphaComponent(0.8).setFill()
        roundedRect.fill()
        
        if Self.withCheckmark {
            // Draw checkmark
            if let image = UIImage(named: "Checkmark") {
                let imagePoint = CGPoint(x: center.x - round(image.size.width / 2),
                                         y: center.y - round(image.size.height / 2) - boxHeight / 8)
                image.draw(at: imagePoint)
            }
            // Draw the text
            let attribs = [
                NSAttributedString.Key.font: UIFont.preferredFont(for: .footnote, weight: .medium),
                NSAttributedString.Key.foregroundColor: UIColor.white]
            let textSize = Self.text.size(withAttributes: attribs)
            let textPoint = CGPoint(
                x: center.x - round(textSize.width / 2),
                y: center.y - round(textSize.height / 2) + (Self.withCheckmark ? boxHeight / 4 : 0))
            Self.text.draw(at: textPoint, withAttributes: attribs)
        } else {
            // Draw label
            let label = UILabel(frame: boxRect)
            label.font = .preferredFont(for: .footnote, weight: .medium)
            label.textColor = .white
            label.textAlignment = .center
            label.numberOfLines = 0
            label.attributedText = Self.attributedText
            self.addSubview(label)
        }
    }
    
    //MARK: - Show/Hide HUDView
    
    func show() {
        alpha = 0
        transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.alpha = 1
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    func hide(afterDelay delay: Double) {
        afterDelay(delay) {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: []) {
                self.alpha = 0
                self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            } completion: { _ in
                self.removeFromSuperview()
            }
        }
    }
}
