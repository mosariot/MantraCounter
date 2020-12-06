//
//  TextViewWithPlaceholder.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 03.12.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

final class TextViewWithPlaceholder: UITextView {
    
    public var placeHolder = UILabel()
    public var placeHolderText = "" {
        didSet {
            setupPlaceholder()
        }
    }
    
    private func setupPlaceholder() {
        placeHolder.text = placeHolderText
        guard let fontSize = font?.pointSize else { return }
        placeHolder.font = .systemFont(ofSize: fontSize)
        placeHolder.sizeToFit()
        placeHolder.frame.origin = CGPoint(x: 5, y: fontSize / 3)
        placeHolder.textColor = .placeholderText
        addSubview(placeHolder)
    }
}
