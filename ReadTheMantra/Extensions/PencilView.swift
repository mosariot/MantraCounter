//
//  PencilView.swift
//  ReadTheMantra
//
//  Created by Александр Воробьев on 09.10.2020.
//  Copyright © 2020 Александр Воробьев. All rights reserved.
//

import UIKit

extension UIView {

    func addPencilMark(color: UIColor) {
        if let pencilImage = UIImage(systemName: "pencil.circle", withConfiguration: UIImage.SymbolConfiguration(weight: .thin))?.withTintColor(color, renderingMode: .alwaysOriginal) {
            let pencilImageView = UIImageView(image: pencilImage)
            pencilImageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            pencilImageView.layer.position = CGPoint(x: self.frame.width-pencilImageView.frame.width/2, y: 0)
            pencilImageView.tag = 1
            self.addSubview(pencilImageView)
            self.bringSubviewToFront(pencilImageView)
        }
    }
}
