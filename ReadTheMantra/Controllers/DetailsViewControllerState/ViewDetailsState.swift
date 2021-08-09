//
//  ViewDetailsState.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 09.08.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

class ViewDetailsState: DetailsViewControllerState {
    
    override func apply(to context: DetailsStateContext) {
        context.navigationItem.title = NSLocalizedString("Information", comment: "Information bar title")
        context.navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .edit,
            primaryAction: UIAction(handler: { [weak context] _ in
                guard let context = context else { return }
                context.editButtonPressed()
            }))
        context.navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .close,
            primaryAction: UIAction(handler: { [weak context] _ in
                guard let context = context else { return }
                context.closeButtonPressed()
            }))
        context.detailsView.setPhotoButton.setViewMode()
        context.detailsView.titleTextField.isUserInteractionEnabled = false
        context.detailsView.mantraTextTextView.isUserInteractionEnabled = false
        context.detailsView.mantraTextTextView.isEditable = false
        context.detailsView.detailsTextView.isUserInteractionEnabled = false
        context.detailsView.detailsTextView.isEditable = false
        context.detailsView.titleTextField.resignFirstResponder()
        context.detailsView.mantraTextTextView.resignFirstResponder()
        context.detailsView.detailsTextView.resignFirstResponder()
        context.detailsView.mantraTextTextView.placeHolder.isHidden = true
        context.detailsView.detailsTextView.placeHolder.isHidden = true
    }
}
