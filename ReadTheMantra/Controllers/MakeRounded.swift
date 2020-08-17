//
//  UIImageViewExtension.swift
//  ReadTheMantra
//
//  Created by Александр Воробьев on 16.08.2020.
//  Copyright © 2020 Александр Воробьев. All rights reserved.
//

import UIKit

extension UIImageView {

    func makeRounded() {
        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.systemGray.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}
