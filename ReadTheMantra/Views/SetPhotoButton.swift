//
//  SetPhotoButton.swift
//  ReadTheMantra
//
//  Created by Александр Воробьев on 30.11.2020.
//  Copyright © 2020 Александр Воробьев. All rights reserved.
//

import UIKit

final class SetPhotoButton: UIButton {
    
    private let activityIndicatorView = UIActivityIndicatorView(style: .large)
    private var editLabel = UILabel()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupActivityIndicatorView()
        setupEditLabel()
        addSubview(activityIndicatorView)
        addSubview(editLabel)
    }
    
    func setEditMode() {
        isUserInteractionEnabled = true
        activityIndicatorView.stopAnimating()
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0.7
            self.editLabel.alpha = 1
        }
    }
    
    func setProcessMode() {
        activityIndicatorView.startAnimating()
    }
    
    func setViewMode() {
        isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
            self.editLabel.alpha = 0
        }
    }
    
    private func setupActivityIndicatorView() {
        activityIndicatorView.center = CGPoint(x: frame.width/2, y: frame.width/2)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.color = .black
    }
    
    private func setupEditLabel() {
        let height: CGFloat = frame.height/6
        editLabel = UILabel(frame: CGRect(x: 0, y: frame.height-height, width: frame.width, height: height))
        editLabel.font = .preferredFont(for: .body, weight: .semibold)
        editLabel.text = NSLocalizedString("EDIT", comment: "Edit mark label")
        editLabel.textColor = .systemBackground
        editLabel.backgroundColor = .systemGray
        editLabel.layer.cornerRadius = 5
        editLabel.layer.masksToBounds = true
        editLabel.textAlignment = .center
        editLabel.alpha = 0
    }
}
