//
//  MantraDetailsButtonsHandler.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 16.08.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

protocol DetailsButtonHandlerContext: UIViewController {
    
    var mantraDataManager: DataManager { get }
    var detailsView: DetailsView! { get }
    var currentState: DetailsViewControllerState { get set }
    var states: (addState: DetailsViewControllerState,
                 editState: DetailsViewControllerState,
                 viewState: DetailsViewControllerState) { get }
    var mantra: Mantra { get }
    var mantraImageData: Data? { get }
    var mantraImageForTableViewData: Data? { get }
    var mantraTitles: [String] { get }
    var addHapticGenerator: UINotificationFeedbackGenerator { get }
}

struct MantraDetailsButtonsHandler: DetailsButtonsHandler {
    
    private weak var context: DetailsButtonHandlerContext?
    
    init(context: DetailsButtonHandlerContext) {
        self.context = context
    }
    
    func addButtonPressed() {
        guard let context = context else { return }
        guard let title = context.detailsView.titleTextField.text else { return }
        if isMantraDuplicating(for: title) {
            showDuplicatingAlert(for: title)
        } else {
            handleAddNewMantra(for: title)
        }
    }
    
    func cancelButtonPressed(_ sender: UIBarButtonItem?) {
        guard let context = context else { return }
        if context.detailsView.titleTextField.text?.trimmingCharacters(in: .whitespaces) == ""
            && context.detailsView.mantraTextTextView.text == ""
            && context.detailsView.detailsTextView.text == ""
            && context.mantraImageData == nil {
            context.mantraDataManager.deleteMantra(context.mantra)
            context.dismiss(animated: true, completion: nil)
            return
        }
        let alert = UIAlertController.cancelOrCloseMantraAlert(sender) { [weak context] in
                guard let context = context else { return }
                context.mantraDataManager.deleteMantra(context.mantra)
                context.dismiss(animated: true, completion: nil)
            }
        context.present(alert, animated: true, completion: nil)
    }
    
    func editButtonPressed() {
        guard let context = context else { return }
        context.currentState = context.states.editState
    }
    
    func doneButtonPressed() {
        guard let context = context else { return }
        guard let title = context.detailsView.titleTextField.text else { return }
        // waiting for autocorrection will apply to detailsTextView
        afterDelay(0.05) {
            self.addNewOrUpdateMantra(with: title)
        }
        context.currentState = context.states.viewState
    }
    
    func closeButtonPressed(_ sender: UIBarButtonItem?) {
        guard let context = context else { return }
        if context.detailsView.titleTextField.text != context.mantra.title
            || context.detailsView.mantraTextTextView.text != context.mantra.text ?? ""
            || context.detailsView.detailsTextView.text != context.mantra.details
            || context.mantraImageData != context.mantra.image {
            let alert = UIAlertController.cancelOrCloseMantraAlert(sender) { [weak context] in
                guard let context = context else { return }
                context.dismiss(animated: true, completion: nil)
            }
            context.present(alert, animated: true, completion: nil)
        } else {
            context.dismiss(animated: true, completion: nil)
        }
    }
    
    private func isMantraDuplicating(for title: String) -> Bool {
        guard let context = context else { return false }
        return context.mantraTitles.contains(where: {$0.caseInsensitiveCompare(title) == .orderedSame})
    }
    
    private func showDuplicatingAlert(for title: String) {
        guard let context = context else { return }
        let alert = UIAlertController.duplicatingAlert(context.navigationItem.rightBarButtonItem) {
            handleAddNewMantra(for: title)
        } cancelActionHandler: { return }
        context.present(alert, animated: true, completion: nil)
    }
    
    private func handleAddNewMantra(for title: String) {
        guard let context = context else { return }
        guard context.detailsView.titleTextField.text?.trimmingCharacters(in: .whitespaces) != "" else {
            let alert = UIAlertController.addTitleAlert()
            context.present(alert, animated: true, completion: nil)
            return
        }
        
        addNewOrUpdateMantra(with: title)
        
        context.addHapticGenerator.notificationOccurred(.success)
        
        HudView.makeViewWithCheckmark(
            inView: context.navigationController?.view ?? context.view,
            withText: NSLocalizedString("Added", comment: "HUD title"))
        afterDelay(0.8) {
            context.dismiss(animated: true, completion: nil)
        }
    }
    
    private func addNewOrUpdateMantra(with title: String) {
        guard let context = context else { return }
        context.mantraDataManager.buildOrUpdateMantra(
            context.mantra,
            title: title,
            text: context.detailsView.mantraTextTextView.text,
            details: context.detailsView.detailsTextView.text,
            imageData: context.mantraImageData,
            imageForTableViewData: context.mantraImageForTableViewData)
    }
}
