//
//  AcitivityIndicatorWithText.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 21.03.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

struct ActivityIndicatorWithText {
    
    let view: UIView
    
    private let viewForActivityIndicator = UIView()
    private let activityIndicatorView = UIActivityIndicatorView()
    private let loadingTextLabel = UILabel()
    
    func showActivityIndicator() {
        viewForActivityIndicator.frame = view.frame
        view.addSubview(viewForActivityIndicator)
        loadingTextLabel.textColor = .secondaryLabel
        loadingTextLabel.text = NSLocalizedString("LOADING", comment: "Loading from iCloud")
        loadingTextLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        loadingTextLabel.sizeToFit()
        loadingTextLabel.center = CGPoint(x: activityIndicatorView.center.x, y: activityIndicatorView.center.y + 25)
        viewForActivityIndicator.addSubview(loadingTextLabel)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.style = .medium
        viewForActivityIndicator.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        viewForActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        viewForActivityIndicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        viewForActivityIndicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
    }
    
    func stopActivityIndicator() {
        viewForActivityIndicator.removeFromSuperview()
        activityIndicatorView.stopAnimating()
        activityIndicatorView.removeFromSuperview()
    }
}
