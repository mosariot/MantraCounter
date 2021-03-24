//
//  AcitivityIndicatorView.swift
//  ReadTheMantra
//
//  Created by Александр Воробьев on 21.03.2021.
//  Copyright © 2021 Александр Воробьев. All rights reserved.
//

import UIKit

struct ActivityIndicator {
    
    let viewForActivityIndicator = UIView()
    let view: UIView
    let activityIndicatorView = UIActivityIndicatorView()
    let loadingTextLabel = UILabel()
    
    func showActivityIndicator() {
        viewForActivityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        view.addSubview(viewForActivityIndicator)
        activityIndicatorView.center = CGPoint(x: self.view.frame.size.width / 2.0, y: (self.view.frame.size.height) / 2.0)
        loadingTextLabel.textColor = .secondaryLabel
        loadingTextLabel.text = NSLocalizedString("LOADING", comment: "Loading from iCloud")
        loadingTextLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        loadingTextLabel.sizeToFit()
        loadingTextLabel.center = CGPoint(x: activityIndicatorView.center.x, y: activityIndicatorView.center.y + 30)
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
