//
//  RoundedStackView.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 10.12.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

extension UIStackView {
    
    func customize(backgroundColor: UIColor = .clear, radiusSize: CGFloat = 15) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = backgroundColor
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        subView.layer.cornerRadius = radiusSize
        insertSubview(subView, at: 0)
    }
}
