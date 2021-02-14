//
//  BlurEffectView.swift
//  ReadTheMantra
//
//  Created by Александр Воробьев on 14.02.2021.
//  Copyright © 2021 Александр Воробьев. All rights reserved.
//

import UIKit

class BlurEffectView: UIView {
    
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
        frame = UIScreen.main.bounds
        blurEffectView.frame = frame
        addSubview(blurEffectView)
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
    
    func updateFrame() {
        blurEffectView.frame = UIScreen.main.bounds
    }
}
