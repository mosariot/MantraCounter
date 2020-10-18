//
//  RoundedSystemFont.swift
//  ReadTheMantra
//
//  Created by Александр Воробьев on 16.10.2020.
//  Copyright © 2020 Александр Воробьев. All rights reserved.
//

import UIKit

extension UIFont {
    class func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
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

