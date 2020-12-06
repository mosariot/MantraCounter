//
//  SetPhotoButton.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 30.11.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

final class SetPhotoButton: UIButton {
    
    //MARK: - Private
    
    private let activityIndicatorView = UIActivityIndicatorView(style: .large)
    private var editLabel = UILabel()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupActivityIndicatorView()
        setupEditLabel()
        addSubview(activityIndicatorView)
        addSubview(editLabel)
    }
    
    private func setupActivityIndicatorView() {
        activityIndicatorView.center = CGPoint(x: frame.width/2, y: frame.width/2)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.color = .black
    }
    
    private func setupEditLabel() {
        let height = frame.height/6
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
    
    //MARK: - Public
    
    public func setEditMode() {
        isUserInteractionEnabled = true
        activityIndicatorView.stopAnimating()
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0.7
            self.editLabel.alpha = 1
        }
    }
    
    public func setProcessMode() {
        isUserInteractionEnabled = true
        activityIndicatorView.startAnimating()
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0.7
            self.editLabel.alpha = 1
        }
    }
    
    public func setViewMode() {
        isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
            self.editLabel.alpha = 0
        }
    }
}
