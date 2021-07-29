//
//  CropToCircleUIImage.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 16.08.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

extension UIImage {
    
    func cropToCircle() -> UIImage? {
        
        let isLandscape = size.width > size.height
        let isUpOrDownImageOrientation = [0,1,4,5].contains(imageOrientation.rawValue)
        
        let breadth: CGFloat = min(size.width, size.height)
        let breadthSize = CGSize(width: breadth, height: breadth)
        let breadthRect = CGRect(origin: .zero, size: breadthSize)
        
        let xOriginPoint = CGFloat(isLandscape ?
                                    (isUpOrDownImageOrientation ? ((size.width-size.height)/2).rounded(.down) : 0) :
                                    (isUpOrDownImageOrientation ? 0 : ((size.height-size.width)/2).rounded(.down)))
        let yOriginPoint = CGFloat(isLandscape ?
                                    (isUpOrDownImageOrientation ? 0 : ((size.width-size.height)/2).rounded(.down)) :
                                    (isUpOrDownImageOrientation ? ((size.height-size.width)/2).rounded(.down) : 0))
        
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: xOriginPoint, y: yOriginPoint),
                                                         size: breadthSize)) else { return nil }
        let format = imageRendererFormat
        format.opaque = false
        
        return UIGraphicsImageRenderer(size: breadthSize, format: format).image { _ in
            UIBezierPath(ovalIn: breadthRect).addClip()
            UIImage(cgImage: cgImage, scale: format.scale, orientation: imageOrientation).draw(in: CGRect(origin: .zero, size: breadthSize))
        }
    }
}
