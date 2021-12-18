//
//  GalleryImagePicker.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 28.11.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit
import PhotosUI

final class GalleryImagePicker {
    
    private var continuation: CheckedContinuation<UIImage, Error>?
    
    init(in caller: UIViewController) {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        if #available (iOS 15, *) {
            if let sheet = picker.presentationController as? UISheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.prefersGrabberVisible = true
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            }
        }
        
        caller.present(picker, animated: true, completion: nil)
    }
    
    func getImage() async throws -> UIImage {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.continuation = continuation
        }
    }
}
    
extension GalleryImagePicker: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        guard !results.isEmpty else { return }
        
        results.forEach { result in
            let provider = result.itemProvider
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self, completionHandler: { [weak self] (object, error) in
                    if let image = object as? UIImage {
                        self?.continuation?.resume(returning: image)
                    }
                    if let error = error {
                        self?.continuation?.resume(throwing: error)
                    }
                })
            }
        }
    }
}
