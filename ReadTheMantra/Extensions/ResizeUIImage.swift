//
//  ResizeUIImage.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 24.04.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

extension UIImage {

    func resize(to targetSize: CGSize) -> UIImage {
        
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        let scaleFactor = min(widthRatio, heightRatio)

        // Compute the new image size that preserves aspect ratio
        let scaledImageRectSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(size: scaledImageRectSize)

        let scaledImage = renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: scaledImageRectSize))
        }

        return scaledImage
    }
}

