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
    
    func setup() {
        titleStackView.customize(backgroundColor: .secondarySystemGroupedBackground, radiusSize: 15)
        mantraTextStackView.customize(backgroundColor: .secondarySystemGroupedBackground, radiusSize: 15)
        detailsStackView.customize(backgroundColor: .secondarySystemGroupedBackground, radiusSize: 15)
        
        titleTextField.autocorrectionType = .no
        mantraTextTextView.autocorrectionType = .no
        
        titleLabel.text = NSLocalizedString("TITLE", comment: "Mantra title label")
        mantraTextLabel.text = NSLocalizedString("MANTRA TEXT", comment: "Mantra text label")
        detailsTextLabel.text = NSLocalizedString("DESCRIPTION", comment: "Mantra description label")
        titleTextField.placeholder = NSLocalizedString("Enter mantra title", comment: "Mantra title placeholder")
        titleTextField.font = UIFont.preferredFont(for: .title2, weight: .medium)
        titleTextField.adjustsFontForContentSizeCategory = true
        mantraTextTextView.placeHolderText = NSLocalizedString("Enter mantra text", comment: "Mantra text placeholder")
        detailsTextView.placeHolderText = NSLocalizedString("Enter mantra description", comment: "Mantra description placeholder")
    }
    
    func setPhotoButtonMenu(imagePickerHandler: @escaping () -> (),
                            defaultImageHandler: @escaping () -> (),
                            searchOnTheInternetHandler: @escaping () -> ()) {
        setPhotoButton.showsMenuAsPrimaryAction = true
        let photoLibraryAction = UIAction(
            title: NSLocalizedString("Photo Library", comment: "Menu Item on DetailsViewController"),
            image: UIImage(systemName: "photo.on.rectangle.angled")) { _ in
                imagePickerHandler()
            }
        let standardImageAction = UIAction(
            title: NSLocalizedString("Standard Image", comment: "Menu Item on DetailsViewController"),
            image: UIImage(systemName: "photo")) { _ in
                defaultImageHandler()
            }
        let searchAction = UIAction(
            title: NSLocalizedString("Search on the Internet", comment: "Menu Item on DetailsViewController"),
            image: UIImage(systemName: "globe")) { _ in
                searchOnTheInternetHandler()
            }
        let photoMenu = UIMenu(children: [photoLibraryAction, standardImageAction, searchAction])
        setPhotoButton.menu = photoMenu
    }
}
