//
//  RoundedSystemFont.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 16.10.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

extension UIFont {
    
    static func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        let font: UIFont
        
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: size)
        } else {
            font = systemFont
        }
        return font
    }
}
