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
    static func makeViewWithCheckmark(inView view: UIView, withText text: String) -> HudView {
        self.text = text
        self.withCheckmark = true
        view.isUserInteractionEnabled = true
        let hudView = makeAndShowHudView(in: view)
        return hudView
    }
    
    @discardableResult
    static func makeViewWithoutCheckmark(inView view: UIView, withText text: NSMutableAttributedString) -> HudView {
        self.attributedText = text
        self.withCheckmark = false
        view.isUserInteractionEnabled = false
        let hudView = makeAndShowHudView(in: view)
        return hudView
    }
    
    private static func makeAndShowHudView(in view: UIView) -> HudView {
        let hudView = HudView()
        view.addSubview(hudView)
        hudView.isOpaque = false
        hudView.show()
        
        hudView.translatesAutoresizingMaskIntoConstraints = false
        hudView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        hudView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        hudView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        hudView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        return hudView
    }
    
    //MARK: - Draw the HUD View
    
    override func draw(_ rect: CGRect) {
        drawTheBox()
        
        if Self.withCheckmark {
            drawCheckmark()
            drawText()
        } else {
            drawLabel()
        }
    }
    
    private func drawTheBox() {
        let fill = UIView()
        fill.backgroundColor = .systemGray.withAlphaComponent(0.8)
        fill.layer.cornerRadius = 10
        addSubview(fill)
        fill.translatesAutoresizingMaskIntoConstraints = false
        fill.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        fill.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        fill.widthAnchor.constraint(equalToConstant: Self.boxSize).isActive = true
        fill.heightAnchor.constraint(equalToConstant: Self.boxSize).isActive = true
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
    
    func show() {
        alpha = 0
        transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.alpha = 1
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    func hide(afterDelay delay: Double, handler: @escaping () -> ()) {
        afterDelay(delay) {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: []) {
                self.alpha = 0
                self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            } completion: { _ in
                handler()
                self.removeFromSuperview()
            }
        }
    }
}
