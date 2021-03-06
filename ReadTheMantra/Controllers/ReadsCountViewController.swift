//
//  ReadsCountViewController.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 30.07.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

final class ReadsCountViewController: UIViewController {
    
    //MARK: - Properties
    
    private lazy var dataProvider = MantraProvider()
    private let mediumHapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let congratulationsGenerator = UINotificationFeedbackGenerator()
    
    private lazy var confettiView = ConfettiView()
    private lazy var noMantraLabel = PlaceholderLabelForEmptyView.makeLabel(
        inView: view,
        withText: NSLocalizedString("No mantra selected", comment: "No mantra selected"),
        textStyle: .title1)
    
    var mantra: Mantra? {
        didSet {
            loadViewIfNeeded()
            mediumHapticGenerator.prepare()
            congratulationsGenerator.prepare()
            guard let mantra = mantra else {
                navigationItem.rightBarButtonItem = nil
                readsCountView.mainStackView.isHidden = true
                noMantraLabel.isHidden = false
                return
            }
            if currentMantra == nil {
                currentMantra = mantra
                previousReadsCount = nil
            }
            if let currentMantra = currentMantra, mantra !== currentMantra {
                self.currentMantra = mantra
                previousReadsCount = nil
                invalidatePreviousState()
            }
            navigationItem.largeTitleDisplayMode = .never
            readsCountView.mainStackView.isHidden = false
            noMantraLabel.isHidden = true
            readsCountView.circularProgressView.goal = Int(mantra.readsGoal)
            readsCountView.circularProgressView.value = Int(mantra.reads)
            setupUI()
        }
    }
    
    private var currentMantra: Mantra? = nil
    private var previousReadsCount: Int32? = nil {
        didSet { setupNavButtons() }
    }
    private var shouldInvalidatePreviousState = false
    private let defaults = UserDefaults.standard
    
    private var readsCountView: ReadsCountView! {
        guard isViewLoaded else { return nil }
        return (view as! ReadsCountView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        defaults.set(true, forKey: "collapseSecondaryViewController")
    }
    
    //MARK: - Setup UI
    
    private func setupNavButtons() {
        guard let mantra = mantra else { return }
        
        let undoButton = UIButton(primaryAction: UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            self.undoButtonPressed()
        }))
        undoButton.setImage(UIImage(systemName: "arrow.uturn.backward.circle"), for: .normal)
        undoButton.isEnabled = previousReadsCount != nil
        
        let infoButton = UIButton(
            type: .infoLight,
            primaryAction: UIAction(handler: { [weak self] _ in
                guard let self = self else { return }
                self.infoButtonPressed()
            }))
        
        let star = mantra.isFavorite ? "star.fill" : "star"
        
        let favoriteButton = UIButton(primaryAction: UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            self.favoriteButtonPressed()
         }))
        favoriteButton.setImage(UIImage(systemName: star), for: .normal)
        
        let buttonStackView = UIStackView.init(arrangedSubviews: [undoButton, favoriteButton, infoButton])
        buttonStackView.distribution = .equalSpacing
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .center
        buttonStackView.spacing = 25
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: buttonStackView)
    }
    
    private func undoButtonPressed() {
        showUndoAlert()
    }
    
    private func infoButtonPressed() {
        guard let mantra = mantra else { return }
        guard let detailsViewController = storyboard?.instantiateViewController(
                identifier: Constants.detailsViewControllerID,
                creator: { coder in
                    return DetailsViewController(
                        mantra: mantra,
                        mode: .view,
                        coder: coder)
                }) else { return }
        let navigationController = UINavigationController(rootViewController: detailsViewController)
        present(navigationController, animated: true)
    }
    
    private func favoriteButtonPressed() {
        guard let mantra = mantra else { return }
        mantra.isFavorite.toggle()
        setupNavButtons()
        mediumHapticGenerator.impactOccurred()
    }
    
    private func setupUI(animated: Bool = false) {
        guard let mantra = mantra else { return }
        
        setupNavButtons()
        getMantraImages()
        
        readsCountView.titleLabel.text = mantra.title
        readsCountView.titleLabel.font = UIFont.preferredFont(for: .largeTitle, weight: .medium)
        readsCountView.titleLabel.adjustsFontForContentSizeCategory = true
        readsCountView.titleLabel.allowsDefaultTighteningForTruncation = true
        readsCountView.readsGoalButton.setTitle(NSLocalizedString("Goal: ",
                                                   comment: "Button on ReadsCountViewController") + Int(mantra.readsGoal).formattedNumber(),
                                 for: .normal)
        animateCircularProgressViewForUpdatedValues(animated: animated)
        
        let standardAppearance = UINavigationBarAppearance()
        let compactAppearance = UINavigationBarAppearance()
        standardAppearance.titleTextAttributes = [.foregroundColor: UIColor.clear]
        compactAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        navigationItem.standardAppearance = standardAppearance
        navigationItem.compactAppearance = compactAppearance
        navigationItem.title = mantra.title
        
        readsCountView.addReadsButton.imageSystemName = "plus.circle.fill"
        readsCountView.addRoundsButton.imageSystemName = "arrow.clockwise.circle.fill"
        readsCountView.setProperValueButton.imageSystemName = "hand.draw.fill"
    }
    
    private func getMantraImages() {
        guard let mantra = mantra else { return }
        let image = (mantra.image != nil) ? UIImage(data: mantra.image!) : UIImage(named: Constants.defaultImage)
        let downsampledPortraitMantraImage = image?.resize(
            to: CGSize(width: readsCountView.portraitMantraImageView.bounds.width == 0 ? readsCountView.landscapeMantraImageView.bounds.width/1.5 : readsCountView.portraitMantraImageView.bounds.width,
                       height: readsCountView.portraitMantraImageView.bounds.height == 0 ? readsCountView.landscapeMantraImageView.bounds.height/1.5 : readsCountView.portraitMantraImageView.bounds.height))
        let downsampledLandscapeMantraImage = image?.resize(
            to: CGSize(width: readsCountView.landscapeMantraImageView.bounds.width == 0 ? readsCountView.portraitMantraImageView.bounds.width*1.5 : readsCountView.landscapeMantraImageView.bounds.width,
                       height: readsCountView.landscapeMantraImageView.bounds.height == 0 ? readsCountView.portraitMantraImageView.bounds.height*1.5 : readsCountView.landscapeMantraImageView.bounds.height))
        readsCountView.portraitMantraImageView.image = downsampledPortraitMantraImage
        readsCountView.landscapeMantraImageView.image = downsampledLandscapeMantraImage
    }
    
    private func animateCircularProgressViewForUpdatedValues(animated: Bool = true) {
        guard let mantra = mantra else { return }
        readsCountView.circularProgressView.setGoalAnimation(to: Int(mantra.readsGoal), animated: animated)
        readsCountView.circularProgressView.setValueAnimation(to: Int(mantra.reads), animated: animated)
    }
    
    //MARK: - Invalidate Previous State
    
    private func invalidatePreviousState() {
        readsCountView.circularProgressView.stopAnimationIfNeeded()
        confettiView.removeFromSuperview()
        shouldInvalidatePreviousState = true
    }
    
    //MARK: - Updating ReadsCount and ReadsGoal
    
    @IBAction private func setGoalButtonPressed(_ sender: UIButton) {
        showUpdatingAlert(updatingType: .goal)
    }
    
    @IBAction private func addReadsButtonPressed(_ sender: UIButton) {
        showUpdatingAlert(updatingType: .reads)
    }
    
    @IBAction private func addRoundsButtonPressed(_ sender: UIButton) {
        showUpdatingAlert(updatingType: .rounds)
    }
    
    @IBAction private func setProperValueButtonPressed(_ sender: UIButton) {
        showUpdatingAlert(updatingType: .properValue)
    }
    
    private func showUpdatingAlert(updatingType: UpdatingType) {
        guard let mantra = mantra else { return }
        let alert = UIAlertController.updatingAlert(mantra: mantra, updatingType: updatingType, delegate: self) { [weak self] (value) in
            guard let self = self else { return }
            self.mediumHapticGenerator.impactOccurred()
            self.handleAlertPositiveAction(forValue: value, updatingType: updatingType)
        }
        present(alert, animated: true, completion: nil)
    }
    
    private func handleAlertPositiveAction(forValue value: Int32, updatingType: UpdatingType) {
        guard let mantra = mantra else { return }
        let oldReads = mantra.reads
        dataProvider.updateValues(for: mantra, with: value, updatingType: updatingType)
        updateProrgessView(for: updatingType)
        readsCountView.readsGoalButton.setTitle(NSLocalizedString("Goal: ",
                                                   comment: "Button on ReadsCountViewController") + Int(mantra.readsGoal).formattedNumber(),
                                 for: .normal)
        if updatingType != .goal {
            previousReadsCount = oldReads
            readsCongratulationsCheck(oldReads: previousReadsCount, newReads: mantra.reads)
        }
    }
    
    private func updateProrgessView(for updatingType: UpdatingType) {
        guard let mantra = mantra else { return }
        switch updatingType {
        case .goal:
            readsCountView.circularProgressView.setGoalAnimation(to: Int(mantra.readsGoal))
        case .reads, .rounds, .properValue:
            readsCountView.circularProgressView.setValueAnimation(to: Int(mantra.reads))
        }
    }
    
    private func readsCongratulationsCheck(oldReads: Int32?, newReads: Int32) {
        guard let mantra = mantra, let oldReads = oldReads else { return }
        shouldInvalidatePreviousState = false
        if (oldReads < mantra.readsGoal/2 && mantra.readsGoal/2..<mantra.readsGoal ~= newReads) {
            afterDelay(Constants.progressAnimationDuration + 0.3) {
                if !self.shouldInvalidatePreviousState {
                    self.showReadsCongratulationsAlert(level: .halfGoal)
                }
            }
        }
        
        if oldReads < mantra.readsGoal && newReads >= mantra.readsGoal {
            congratulationsGenerator.notificationOccurred(.success)
            confettiView = ConfettiView.makeView(inView: splitViewController?.view ?? view, animated: true)
            confettiView.startConfetti()
            
            afterDelay(Constants.progressAnimationDuration + 1.8) {
                if !self.shouldInvalidatePreviousState {
                    self.showReadsCongratulationsAlert(level: .fullGoal)
                }
            }
        }
    }
    
    private func showReadsCongratulationsAlert(level: Level) {
        let alert = UIAlertController.congratulationsAlert(level: level)
        present(alert, animated: true, completion: nil)
    }
    
    private func showUndoAlert() {
        let alert = UIAlertController.undoAlert { [weak self] in
            guard let self = self else { return }
            self.mediumHapticGenerator.impactOccurred()
            self.undoReadsCount()
        }
        present(alert, animated: true, completion: nil)
    }
    
    private func undoReadsCount() {
        guard let mantra = mantra, let previousReadsCount = previousReadsCount else { return }
        mantra.reads = previousReadsCount
        readsCountView.circularProgressView.value = Int(previousReadsCount)
        setupUI()
        self.previousReadsCount = nil
    }
}

//MARK: - MantraViewControllerDelegate

extension ReadsCountViewController: MantraViewControllerDelegate {
    
    func mantraSelected(_ newMantra: Mantra?) {
        mantra = newMantra
    }
}

//MARK: - TextFieldDelegate

extension ReadsCountViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) else {
            return false
        }
        return true
    }
}
