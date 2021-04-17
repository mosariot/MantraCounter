//
//  AcitivityIndicatorView.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 21.03.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

struct ActivityIndicator {
    
    let viewForActivityIndicator = UIView()
    let view: UIView
    let activityIndicatorView = UIActivityIndicatorView()
    let loadingTextLabel = UILabel()
    
    func showActivityIndicator() {
        viewForActivityIndicator.frame = view.bounds
        view.addSubview(viewForActivityIndicator)
        activityIndicatorView.center = CGPoint(x: view.bounds.size.width / 2.0, y: (view.bounds.size.height) / 2.0)
        loadingTextLabel.textColor = .secondaryLabel
        loadingTextLabel.text = NSLocalizedString("LOADING", comment: "Loading from iCloud")
        loadingTextLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        loadingTextLabel.sizeToFit()
        loadingTextLabel.center = CGPoint(x: activityIndicatorView.center.x, y: activityIndicatorView.center.y + 35)
        viewForActivityIndicator.addSubview(loadingTextLabel)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.style = .large
        viewForActivityIndicator.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
    }
    
    func stopActivityIndicator() {
        viewForActivityIndicator.removeFromSuperview()
        activityIndicatorView.stopAnimating()
        activityIndicatorView.removeFromSuperview()
    }
}
