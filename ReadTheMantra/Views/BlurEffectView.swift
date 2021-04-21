//
//  BlurEffectView.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 14.02.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

final class BlurEffectView: UIVisualEffectView {
    
    //MARK: - Convinient initializer
    
    static func makeView(inView view: UIView) -> BlurEffectView {
        let blurView = BlurEffectView(frame: view.bounds)
        view.addSubview(blurView)
        blurView.effect = UIBlurEffect(style: .light)
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        return blurView
    }
    
    //MARK: - Show Methods
    
    func animateIn() {
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
