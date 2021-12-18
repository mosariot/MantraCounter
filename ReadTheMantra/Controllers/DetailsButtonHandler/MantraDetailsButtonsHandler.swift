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
            Task { await showDuplicatingAlert(for: title) }
        } else {
            handleAddNewMantra(for: title)
        }
    }
    
    @MainActor
    func cancelButtonPressed(_ sender: UIBarButtonItem?) async {
        guard let context = context else { return }
        if context.detailsView.titleTextField.text?.trimmingCharacters(in: .whitespaces) == ""
            && context.detailsView.mantraTextTextView.text == ""
            && context.detailsView.detailsTextView.text == ""
            && context.mantraImageData == nil {
            context.mantraDataManager.deleteMantra(context.mantra)
            context.dismiss(animated: true, completion: nil)
            return
        }
        
        if await AlertCenter.confirmCancelMantra(in: context, with: sender) {
            context.mantraDataManager.deleteMantra(context.mantra)
            context.dismiss(animated: true, completion: nil)
        }
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
    
    @MainActor
    func closeButtonPressed(_ sender: UIBarButtonItem?) async {
        guard let context = context else { return }
        if context.detailsView.titleTextField.text != context.mantra.title
            || context.detailsView.mantraTextTextView.text != context.mantra.text ?? ""
            || context.detailsView.detailsTextView.text != context.mantra.details
            || context.mantraImageData != context.mantra.image {
            if await AlertCenter.confirmDiscardChanges(in: context, with: sender) {
                context.dismiss(animated: true, completion: nil)
            }
        } else {
            context.dismiss(animated: true, completion: nil)
        }
    }
    
    private func isMantraDuplicating(for title: String) -> Bool {
        guard let context = context else { return false }
        return context.mantraTitles.contains(where: {$0.caseInsensitiveCompare(title) == .orderedSame})
    }
    
    private func showDuplicatingAlert(for title: String) async {
        guard let context = context else { return }
        if await AlertCenter.confirmDuplicationOfMantra(in: context, with: context.navigationItem.rightBarButtonItem) {
            handleAddNewMantra(for: title)
        } else {
            return
        }
    }
    
    private func handleAddNewMantra(for title: String) {
        guard let context = context else { return }
        guard context.detailsView.titleTextField.text?.trimmingCharacters(in: .whitespaces) != "" else {
            AlertCenter.showAddTitleAlert(in: context)
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
