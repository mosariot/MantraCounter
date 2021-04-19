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
        
        addSubview(activityIndicatorView)
        addSubview(editLabel)
        setupActivityIndicatorView()
        setupEditLabel()
    }
    
    private func setupActivityIndicatorView() {
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.color = .black
        
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        activityIndicatorView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        activityIndicatorView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        activityIndicatorView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    private func setupEditLabel() {
        editLabel.font = .preferredFont(for: .body, weight: .semibold)
        editLabel.text = NSLocalizedString("EDIT", comment: "Edit mark label")
        editLabel.textColor = .systemBackground
        editLabel.backgroundColor = .systemGray
        editLabel.layer.cornerRadius = 5
        editLabel.layer.masksToBounds = true
        editLabel.textAlignment = .center
        editLabel.alpha = 0
        
        editLabel.translatesAutoresizingMaskIntoConstraints = false
        editLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: frame.height*5/6).isActive = true
        editLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        editLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        editLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
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
        activityIndicatorView.stopAnimating()
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
            self.editLabel.alpha = 0
        }
    }
}
