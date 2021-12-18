//
//  SafariImagePicker.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 28.11.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit
import SafariServices

final class SafariImagePicker: NSObject {
    
    private var continuation: CheckedContinuation<UIImage, Never>?
    
    init(in caller: UIViewController, search: String) {
        super.init()
        guard let urlString = "https://www.google.com/search?q=\(search)&tbm=isch"
                .addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else { return }
        guard let url = URL(string: urlString) else { return }
        let vc = SFSafariViewController(url: url)
        vc.delegate = self
        vc.modalPresentationStyle = .pageSheet
        vc.preferredControlTintColor = caller.view.tintColor
        
        if #available (iOS 15, *) {
            if let sheet = vc.presentationController as? UISheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.prefersGrabberVisible = true
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            }
        }
        
        caller.present(vc, animated: true) {
            self.checkForFirstSearchOnTheInternet { [weak vc] (alert) in
                guard let vc = vc else { return }
                vc.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func getImage() async -> UIImage {
        await withCheckedContinuation { [weak self] continuation in
            self?.continuation = continuation
        }
    }
    
    private func checkForFirstSearchOnTheInternet(handler: @escaping (UIAlertController) -> ()) {
        let defaults = UserDefaults.standard
        let isFirstSearchOnTheInternet = defaults.bool(forKey: "isFirstSearchOnTheInternet")
        if isFirstSearchOnTheInternet {
            let alert = AlertCenter.firstSearchOnTheInternetAlert()
            defaults.setValue(false, forKey: "isFirstSearchOnTheInternet")
            handler(alert)
        }
    }
}
    
extension SafariImagePicker: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if UIPasteboard.general.hasImages {
            guard let image = UIPasteboard.general.image else { return }
            continuation?.resume(returning: image)
        } else if UIPasteboard.general.hasURLs {
            guard let url = UIPasteboard.general.url else { return }
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    continuation?.resume(returning: image)
                }
            }
        }
        UIPasteboard.general.items.removeAll()
    }
}
