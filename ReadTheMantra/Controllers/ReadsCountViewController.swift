//
//  ReadsCountViewController.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 30.07.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

final class ReadsCountViewController: UIViewController, ReadsCountStateContext {
        
    //MARK: - Properties
    
    private(set) var mantraManager: DataManager = MantraManager()
    private let defaults = UserDefaults.standard
    private let mediumHapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    private lazy var states: (alwaysOnDisplay: ReadsCountViewControllerState,
                              displaySystemBehavior: ReadsCountViewControllerState) =
        (alwaysOnDisplay: AlwaysOnDisplayState(context: self),
         displaySystemBehavior: DisplaySystemBehaviorState(context: self))
    private lazy var currentState: ReadsCountViewControllerState = states.displaySystemBehavior {
        didSet { currentState.apply() }
    }
    
    var previousReadsCount: Int32? = nil {
        didSet { setupNavButtons() }
    }
    var shouldInvalidatePreviousState = false
    
    lazy var confettiView = ConfettiView()
    private lazy var noMantraLabel = PlaceholderLabelForEmptyView.makeLabel(
        inView: view,
        withText: NSLocalizedString("No mantra selected", comment: "No mantra selected"),
        textStyle: .title1)
    
    var readsCountView: ReadsCountView! {
        guard isViewLoaded else { return nil }
        return (view as! ReadsCountView)
    }
    
    private var noMantraSelected = false {
        didSet {
            switch noMantraSelected {
            case true:
                navigationItem.rightBarButtonItem = nil
                readsCountView.mainStackView.isHidden = true
                readsCountView.displayAlwaysOn.isHidden = true
                noMantraLabel.isHidden = false
            case false:
                readsCountView.mainStackView.isHidden = false
                readsCountView.displayAlwaysOn.isHidden = false
                noMantraLabel.isHidden = true
            }
        }
    }
    
    private var currentMantra: Mantra? = nil
    
    private(set) var mantra: Mantra? {
        didSet {
            loadViewIfNeeded()
            mediumHapticGenerator.prepare()
            guard let mantra = mantra else {
                noMantraSelected = true
                return
            }
            if currentMantra == nil {
                currentState = states.displaySystemBehavior
                currentMantra = mantra
                previousReadsCount = nil
            }
            if let currentMantra = currentMantra, mantra !== currentMantra {
                currentState = states.displaySystemBehavior
                self.currentMantra = mantra
                previousReadsCount = nil
                invalidatePreviousState()
            }
            navigationItem.largeTitleDisplayMode = .never
            noMantraSelected = false
            readsCountView.circularProgressView.goal = Int(mantra.readsGoal)
            readsCountView.circularProgressView.value = Int(mantra.reads)
            setupUI()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        currentState = states.displaySystemBehavior
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        defaults.set(true, forKey: "collapseSecondaryViewController")
    }
    
    //MARK: - Setup UI
    private func setupUI() {
        guard let mantra = mantra else { return }
        
        setupNavButtons()
        setMantraImages()
        
        readsCountView.titleLabel.text = mantra.title
        readsCountView.titleLabel.font = UIFont.preferredFont(for: .largeTitle, weight: .medium)
        readsCountView.titleLabel.adjustsFontForContentSizeCategory = true
        readsCountView.titleLabel.allowsDefaultTighteningForTruncation = true
        readsCountView.readsGoalButton.setTitle(NSLocalizedString("Goal: ",
                                                   comment: "Button on ReadsCountViewController") + Int(mantra.readsGoal).formattedNumber(),
                                 for: .normal)
        setCircularProgressViewForUpdatedValues()
        
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
                        state: .viewDetailsState(),
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
    
    private func setMantraImages() {
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
    
    private func setCircularProgressViewForUpdatedValues(animated: Bool = false) {
        guard let mantra = mantra else { return }
        readsCountView.circularProgressView.setNewGoal(to: Int(mantra.readsGoal), animated: animated)
        readsCountView.circularProgressView.setNewValue(to: Int(mantra.reads), animated: animated)
    }
    
    //MARK: - Invalidate Previous State
    
    private func invalidatePreviousState() {
        readsCountView.circularProgressView.stopAnimationIfNeeded()
        confettiView.removeFromSuperview()
        shouldInvalidatePreviousState = true
    }
    
    // MARK: - Display Always On Stack
    
    @IBAction func displayAlwaysOnPressed(_ sender: UIButton) {
        checkForFirstSwitchDisplayMode()
        switch currentState {
        case is AlwaysOnDisplayState:
            currentState = states.displaySystemBehavior
        case is DisplaySystemBehaviorState:
            currentState = states.alwaysOnDisplay
        default:
            currentState = states.displaySystemBehavior
        }
    }
    
    private func checkForFirstSwitchDisplayMode() {
        let defaults = UserDefaults.standard
        let isFirstSwitchDisplayMode = defaults.bool(forKey: "isFirstSwitchDisplayMode")
        if isFirstSwitchDisplayMode {
            let alert = UIAlertController.firstSwitchDisplayMode()
            present(alert, animated: true)
            defaults.setValue(false, forKey: "isFirstSwitchDisplayMode")
        }
    }
    
    //MARK: - Adjusting ReadsCount and ReadsGoal
    
    @IBAction private func setGoalButtonPressed(_ sender: UIButton) {
        currentState.handleAdjustMantraCount(adjustingType: .goal)
    }
    
    @IBAction private func addReadsButtonPressed(_ sender: UIButton) {
        currentState.handleAdjustMantraCount(adjustingType: .reads)
    }
    
    @IBAction private func addRoundsButtonPressed(_ sender: UIButton) {
        currentState.handleAdjustMantraCount(adjustingType: .rounds)
    }
    
    @IBAction private func setProperValueButtonPressed(_ sender: UIButton) {
        currentState.handleAdjustMantraCount(adjustingType: .properValue)
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
