//
//  BlurEffectView.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 14.02.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

final class BlurEffectView: UIView {
    
    let blurEffect = UIBlurEffect(style: .light)
    lazy var blurEffectView = UIVisualEffectView(effect: blurEffect)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        addSubview(blurEffectView)
        
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        blurEffectView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        blurEffectView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        blurEffectView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        UIView.animate(withDuration: 0.5) {
            self.alpha =  1
        }
    }
    
    func animateOut() {
        UIView.animate(withDuration: 0.8) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}
