//
//  DetailView.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 29.06.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

final class DetailsView: UIView {
    
    @IBOutlet var setPhotoButton: SetPhotoButton!
    
    @IBOutlet var titleStackView: UIStackView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var titleTextField: UITextField!
    
    @IBOutlet var mantraTextStackView: UIStackView!
    @IBOutlet var mantraTextLabel: UILabel!
    @IBOutlet var mantraTextTextView: TextViewWithPlaceholder!
    
    @IBOutlet var detailsStackView: UIStackView!
    @IBOutlet var detailsTextLabel: UILabel!
    @IBOutlet var detailsTextView: TextViewWithPlaceholder!
}
