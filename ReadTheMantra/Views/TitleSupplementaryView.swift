//
//  TitleSupplementaryView.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 05.02.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

class TitleSupplementaryView: UICollectionReusableView {
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

extension TitleSupplementaryView {
    func configure() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
        label.font = UIFont.preferredFont(forTextStyle: .headline)
    }
}
