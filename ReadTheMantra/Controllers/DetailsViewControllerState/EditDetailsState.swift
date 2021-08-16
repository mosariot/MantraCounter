//
//  EditDetailsState.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 09.08.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

class EditDetailsState: DetailsViewControllerState {
    
    override func apply(to context: DetailsStateContext) {
        context.title = NSLocalizedString("Information", comment: "Information bar title")
        context.navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .done,
            primaryAction: UIAction(handler: { [weak context] _ in
                guard let context = context else { return }
                context.mantraHandler.doneButtonPressed()
            }))
        context.navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .close,
            primaryAction: UIAction(handler: { [weak context] _ in
                guard let context = context else { return }
                context.mantraHandler.closeButtonPressed()
            }))
        context.detailsView.setPhotoButton.setEditMode()
        context.detailsView.titleTextField.isUserInteractionEnabled = true
        context.detailsView.mantraTextTextView.isUserInteractionEnabled = true
        context.detailsView.mantraTextTextView.isEditable = true
        context.detailsView.detailsTextView.isUserInteractionEnabled = true
        context.detailsView.detailsTextView.isEditable = true
        context.detailsView.titleTextField.becomeFirstResponder()
        context.detailsView.mantraTextTextView.placeHolder.isHidden = !context.detailsView.mantraTextTextView.text.isEmpty
        context.detailsView.detailsTextView.placeHolder.isHidden = !context.detailsView.detailsTextView.text.isEmpty
    }
}
