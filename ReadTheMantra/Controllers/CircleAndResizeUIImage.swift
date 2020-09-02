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
        let isPortrait =  size.height > size.width
        let isLandscape = size.width > size.height
        let breadth: CGFloat = min(size.width, size.height)
        let breadthSize = CGSize(width: breadth, height: breadth)
        let breadthRect = CGRect(origin: .zero, size: breadthSize)
        
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? ((size.width-size.height)/2).rounded(.down) : 0,
                                                                         y: isPortrait  ? ((size.height-size.width)/2).rounded(.down) : 0),
                                                         size: breadthSize)) else { return nil }
        let format = imageRendererFormat
        format.opaque = false
        return UIGraphicsImageRenderer(size: breadthSize, format: format).image { _ in
            UIBezierPath(ovalIn: breadthRect).addClip()
            UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation).draw(in: CGRect(origin: .zero, size: breadthSize))
        }
    }
    
    func resize(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
