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
    private static let boxSize = 96.0
    
    //MARK: - Convenient initializer
    
    @discardableResult
    static func makeViewWithCheckmark(inView view: UIView, withText text: String, verticalOffset offset: CGFloat = 0) -> HudView {
        self.text = text
        self.withCheckmark = true
        view.isUserInteractionEnabled = false
        let hudView = makeAndShowHudView(in: view)
        hudView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: offset).isActive = true
        return hudView
    }
    
    @discardableResult
    static func makeViewWithoutCheckmark(inView view: UIView, withText text: NSMutableAttributedString, verticalOffset offset: CGFloat = 0) -> HudView {
        self.attributedText = text
        self.withCheckmark = false
        let hudView = makeAndShowHudView(in: view)
        hudView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -offset).isActive = true
        return hudView
    }
    
    private static func makeAndShowHudView(in view: UIView) -> HudView {
        let hudView = HudView()
        view.addSubview(hudView)
        hudView.isOpaque = false
        hudView.show()
        
        hudView.translatesAutoresizingMaskIntoConstraints = false
        hudView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        hudView.widthAnchor.constraint(equalToConstant: Self.boxSize).isActive = true
        hudView.heightAnchor.constraint(equalToConstant: Self.boxSize).isActive = true
        
        return hudView
    }
    
    //MARK: - Draw the HUD View
    
    override func draw(_ rect: CGRect) {
        drawBox()
        
        if Self.withCheckmark {
            drawCheckmark()
            drawText()
        } else {
            drawLabel()
        }
    }
    
    private func drawBox() {
        let box = UIView()
        box.backgroundColor = .systemGray.withAlphaComponent(0.9)
        box.layer.cornerRadius = 10
        addSubview(box)
        
        box.translatesAutoresizingMaskIntoConstraints = false
        box.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        box.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        box.widthAnchor.constraint(equalToConstant: Self.boxSize).isActive = true
        box.heightAnchor.constraint(equalToConstant: Self.boxSize).isActive = true
    }
    
    private func drawCheckmark() {
        if let image = UIImage(named: "Checkmark") {
            let imageView = UIImageView(image: image)
            addSubview(imageView)
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -Self.boxSize / 8).isActive = true
        }
    }
    
    private func drawText() {
        let label = UILabel()
        label.font = .preferredFont(for: .footnote, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = Self.text
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: Self.boxSize / 4).isActive = true
    }
    
    private func drawLabel() {
        let label = UILabel()
        label.font = .preferredFont(for: .footnote, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.attributedText = Self.attributedText
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    //MARK: - Show/Hide HUDView
    
    private func show() {
        alpha = 0
        transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.alpha = 1
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    func hide(afterDelay delay: Double) {
        afterDelay(delay) {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: []) {
                self.alpha = 0
                self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            } completion: { _ in
                self.removeFromSuperview()
            }
        }
    }
}
