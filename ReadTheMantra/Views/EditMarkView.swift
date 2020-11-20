//
//  EditMarkView.swift
//  ReadTheMantra
//
//  Created by Александр Воробьев on 09.10.2020.
//  Copyright © 2020 Александр Воробьев. All rights reserved.
//

import UIKit

extension UIView {

    func addEditMark(color: UIColor) {
        let height: CGFloat = 25
        let editLabel = UILabel(frame: CGRect(x: 0, y: self.frame.height-height, width: self.frame.width, height: height))
        editLabel.font = .preferredFont(for: .body, weight: .semibold)
        editLabel.text = NSLocalizedString("EDIT", comment: "Edit mark label")
        editLabel.textColor = .systemBackground
        editLabel.backgroundColor = .systemGray
        editLabel.layer.cornerRadius = 5
        editLabel.layer.masksToBounds = true
        editLabel.textAlignment = .center
        editLabel.tag = 1
        self.addSubview(editLabel)
        self.bringSubviewToFront(editLabel)
    }
}
