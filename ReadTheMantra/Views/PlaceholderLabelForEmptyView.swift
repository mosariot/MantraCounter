//
//  PlaceholderLabelForEmptyView.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 18.04.2021.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

final class PlaceholderLabelForEmptyView: UILabel {
    
    //MARK: - Convinient initializer
    
    class func label(inView view: UIView, withText text: String, textStyle: UIFont.TextStyle) -> PlaceholderLabelForEmptyView {
        let label = PlaceholderLabelForEmptyView(frame: view.frame)
        label.text = text
        label.font = UIFont.preferredFont(forTextStyle: textStyle)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.sizeToFit()
        label.textAlignment = .center
        view.addSubview(label)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -view.frame.size.height/5).isActive = true
        return label
    }
}
