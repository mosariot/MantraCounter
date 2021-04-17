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
    
    private lazy var coreDataManager = (UIApplication.shared.delegate as! AppDelegate).coreDataManager
    private var dataProvider = MantraProvider()
    
    private lazy var confettiView = ConfettiView(frame: view.frame)
    
    var mantra: Mantra? {
        didSet {
            loadViewIfNeeded()
            guard let mantra = mantra else {
                navigationItem.rightBarButtonItem = nil
                mainStackView.isHidden = true
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
            mainStackView.isHidden = false
            circularProgressView.goal = Int(mantra.readsGoal)
            circularProgressView.value = Int(mantra.reads)
            setupUI()
        }
    }
    
    private var currentMantra: Mantra? = nil
    private var previousReadsCount: Int32? = nil {
        didSet { setupNavButtons() }
    }
    private var shouldInvalidatePreviousState = false
    private let defaults = UserDefaults.standard
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        defaults.set(true, forKey: "collapseSecondaryViewController")
    }
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var portraitMantraImageView: UIImageView!
    @IBOutlet private weak var landscapeMantraImageView: UIImageView!
    @IBOutlet private weak var titleLabel: CopyableLabel!
    @IBOutlet private weak var addRoundsButton: AdjustReadsButton!
    @IBOutlet private weak var addReadsButton: AdjustReadsButton!
    @IBOutlet private weak var setProperValueButton: AdjustReadsButton!
    @IBOutlet private weak var circularProgressView: CircularProgressView!
    @IBOutlet private weak var readsGoalButton: UIButton!
    @IBOutlet private weak var mainStackView: UIStackView!
    
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
    }
    
    private func setupUI(animated: Bool = false) {
        guard let mantra = mantra else { return }
        
        setupNavButtons()
        getMantraImages()
        
        titleLabel.text = mantra.title
        titleLabel.font = UIFont.preferredFont(for: .largeTitle, weight: .medium)
        titleLabel.adjustsFontForContentSizeCategory = true
        readsGoalButton.setTitle(NSLocalizedString("Goal: ",
                                                   comment: "Button on ReadsCountViewController") + Int(mantra.readsGoal).stringFormattedWithSpaces(),
                                 for: .normal)
        animateCircularProgressViewForUpdatedValues(animated: animated)
        
        let standardAppearance = UINavigationBarAppearance()
        let compactAppearance = UINavigationBarAppearance()
        standardAppearance.titleTextAttributes = [.foregroundColor: UIColor.clear]
        compactAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        navigationItem.standardAppearance = standardAppearance
        navigationItem.compactAppearance = compactAppearance
        navigationItem.title = mantra.title
        
        addReadsButton.imageSystemName = "plus.circle.fill"
        addRoundsButton.imageSystemName = "arrow.clockwise.circle.fill"
        setProperValueButton.imageSystemName = "hand.draw.fill"
    }
    
    private func getMantraImages() {
        guard let mantra = mantra else { return }
        let image = (mantra.image != nil) ? UIImage(data: mantra.image!) : UIImage(named: Constants.defaultImage)
        let downsampledPortraitMantraImage = image?.resize(
            to: CGSize(width: portraitMantraImageView.bounds.width == 0 ? landscapeMantraImageView.bounds.width/1.5 : portraitMantraImageView.bounds.width,
                       height: portraitMantraImageView.bounds.height == 0 ?  landscapeMantraImageView.bounds.height/1.5 : portraitMantraImageView.bounds.height))
        let downsampledLandscapeMantraImage = image?.resize(
            to: CGSize(width: landscapeMantraImageView.bounds.width == 0 ? portraitMantraImageView.bounds.width*1.5 : landscapeMantraImageView.bounds.width,
                       height: landscapeMantraImageView.bounds.height == 0 ?  portraitMantraImageView.bounds.height*1.5 : landscapeMantraImageView.bounds.height))
        portraitMantraImageView.image = downsampledPortraitMantraImage
        landscapeMantraImageView.image = downsampledLandscapeMantraImage
    }
    
    private func animateCircularProgressViewForUpdatedValues(animated: Bool = true) {
        guard let mantra = mantra else { return }
        circularProgressView.setGoalAnimation(to: Int(mantra.readsGoal), animated: animated)
        circularProgressView.setValueAnimation(to: Int(mantra.reads), animated: animated)
    }
    
    //MARK: - Invalidate Previous State
    
    private func invalidatePreviousState() {
        circularProgressView.stopAnimationIfNeeded()
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
            self.handleAlertPositiveAction(forValue: value, updatingType: updatingType)
        }
        present(alert, animated: true, completion: nil)
    }
    
    private func handleAlertPositiveAction(forValue value: Int32, updatingType: UpdatingType) {
        guard let mantra = mantra else { return }
        let oldReads = mantra.reads
        dataProvider.updateValues(for: mantra, with: value, updatingType: updatingType)
        updateProrgessView(for: updatingType)
        readsGoalButton.setTitle(NSLocalizedString("Goal: ",
                                                   comment: "Button on ReadsCountViewController") + Int(mantra.readsGoal).stringFormattedWithSpaces(),
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
            circularProgressView.setGoalAnimation(to: Int(mantra.readsGoal))
        case .reads, .rounds, .properValue:
            circularProgressView.setValueAnimation(to: Int(mantra.reads))
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
            confettiView = ConfettiView(frame: view.frame)
            view.addSubview(confettiView)
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
            self.undoReadsCount()
        }
        present(alert, animated: true, completion: nil)
    }
    
    private func undoReadsCount() {
        guard let mantra = mantra, let previousReadsCount = previousReadsCount else { return }
        mantra.reads = previousReadsCount
        circularProgressView.value = Int(previousReadsCount)
        setupUI()
        self.previousReadsCount = nil
    }
}

//MARK: - MantraSelection Delegate

extension ReadsCountViewController: MantraSelectionDelegate {
    
    func mantraSelected(_ newMantra: Mantra?) {
        mantra = newMantra
    }
}

//MARK: - TextField Delegate

extension ReadsCountViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) else {
            return false
        }
        return true
    }
}
