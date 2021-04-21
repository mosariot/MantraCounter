//
//  ActivityIndicatorViewWithText.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 21.03.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

final class ActivityIndicatorViewWithText: UIView {
    
    //MARK: - Convinient initializer
    
    static func makeView(inView view: UIView, withText: String) -> UIView {
        let viewForActivityIndicator = UIView(frame: view.bounds)
        view.addSubview(viewForActivityIndicator)
        
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.style = .medium
        viewForActivityIndicator.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        let loadingTextLabel = UILabel()
        loadingTextLabel.textColor = .secondaryLabel
        loadingTextLabel.text = withText
        loadingTextLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        loadingTextLabel.sizeToFit()
        loadingTextLabel.center = CGPoint(x: activityIndicatorView.center.x, y: activityIndicatorView.center.y + 25)
        viewForActivityIndicator.addSubview(loadingTextLabel)
        
        viewForActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        viewForActivityIndicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        viewForActivityIndicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        return viewForActivityIndicator
    }
}
