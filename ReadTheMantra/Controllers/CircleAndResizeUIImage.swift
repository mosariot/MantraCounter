//
//  UIImageViewExtension.swift
//  ReadTheMantra
//
//  Created by Александр Воробьев on 16.08.2020.
//  Copyright © 2020 Александр Воробьев. All rights reserved.
//

import UIKit

extension UIImage {
    
    func circle() -> UIImage? {
        let square = size.width < size.height ? CGSize(width: size.width, height: size.width) : CGSize(width: size.height, height: size.height)
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = square.width / 2
        imageView.layer.borderColor = UIColor.systemGray.cgColor
        imageView.layer.borderWidth = 10
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContext(imageView.bounds.size)
        if let uiGraphicsGetCurrentContext = UIGraphicsGetCurrentContext() {
            imageView.layer.render(in: uiGraphicsGetCurrentContext)
        }
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    func resizeSquaredImage(targetSize: Int) -> UIImage? {
        let newSize = CGSize(width: targetSize, height: targetSize)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}
