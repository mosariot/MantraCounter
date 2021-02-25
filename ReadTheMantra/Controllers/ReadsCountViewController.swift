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
    
    var mantra: Mantra? {
        didSet {
            loadViewIfNeeded()
            if let mantra = mantra {
                navigationItem.largeTitleDisplayMode = .never
                mainStackView.isHidden = false
                setupNavButtons()
                circularProgressView.goal = Int(mantra.readsGoal)
                circularProgressView.value = Int(mantra.reads)
                setupUI(animated: false)
            } else {
                navigationItem.rightBarButtonItems = nil
                mainStackView.isHidden = true
            }
        }
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
        let infoButton = UIButton(type: .infoLight,
                                  primaryAction: UIAction(handler: { [weak self] _ in
                                    guard let self = self else { return }
                                    self.infoButtonPressed()
                                  }))
        let infoButtonItem = UIBarButtonItem(customView: infoButton)
        
        let star = mantra.isFavorite ? "star.fill" : "star"
        let favoriteButtonItem = UIBarButtonItem(image: UIImage(systemName: star),
                                                 primaryAction: UIAction(handler: { [weak self] _ in
                                                    guard let self = self else { return }
                                                    self.favoriteButtonPressed()
                                                 }))
        favoriteButtonItem.style = .plain
        navigationItem.rightBarButtonItems = [infoButtonItem, favoriteButtonItem]
    }
    
    private func infoButtonPressed() {
        guard let mantra = mantra else { return }
        guard let detailsViewController = storyboard?.instantiateViewController(
                identifier: Constants.detailsViewControllerID,
                creator: { [weak self] coder in
                    guard let self = self else { fatalError() }
                    return DetailsViewController(mantra: mantra,
                                                 mode: .view,
                                                 delegate: self, coder: coder)
                }) else { return }
        let navigationController = UINavigationController(rootViewController: detailsViewController)
        present(navigationController, animated: true)
    }
    
    private func favoriteButtonPressed() {
        guard let mantra = mantra else { return }
        mantra.isFavorite.toggle()
        setupNavButtons()
    }
    
    private func setupUI(animated: Bool = true) {
        guard let mantra = mantra else { return }
        
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
        let downsampledPortraitMantraImage = image?.resize(to: CGSize(width: portraitMantraImageView.bounds.width == 0 ? landscapeMantraImageView.bounds.width/1.5 : portraitMantraImageView.bounds.width,
                                                                      height: portraitMantraImageView.bounds.height == 0 ?  landscapeMantraImageView.bounds.height/1.5 : portraitMantraImageView.bounds.height))
        let downsampledLandscapeMantraImage = image?.resize(to: CGSize(width: landscapeMantraImageView.bounds.width == 0 ? portraitMantraImageView.bounds.width*1.5 : landscapeMantraImageView.bounds.width,
                                                                       height: landscapeMantraImageView.bounds.height == 0 ?  portraitMantraImageView.bounds.height*1.5 : landscapeMantraImageView.bounds.height))
        portraitMantraImageView.image = downsampledPortraitMantraImage
        landscapeMantraImageView.image = downsampledLandscapeMantraImage
    }
    
    private func animateCircularProgressViewForUpdatedValues(animated: Bool = true) {
        guard let mantra = mantra else { return }
        circularProgressView.setGoalAnimation(to: Int(mantra.readsGoal), animated: animated)
        circularProgressView.setValueAnimation(to: Int(mantra.reads), animated: animated)
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
        let alert = UIAlertController.UpdatingAlert(mantra: mantra, updatingType: updatingType) { (value) in
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
        readsCongratulationsCheck(oldReads: oldReads, newReads: mantra.reads)
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
    
    private func readsCongratulationsCheck(oldReads: Int32, newReads: Int32) {
        guard let mantra = mantra else { return }
        if (oldReads < mantra.readsGoal/2 && mantra.readsGoal/2..<mantra.readsGoal ~= newReads) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Constants.progressAnimationDuration + 0.3) {
                self.showReadsCongratulationsAlert(level: .halfGoal)
            }
        }
        
        if oldReads < mantra.readsGoal && newReads >= mantra.readsGoal {
            let confettiView = ConfettiView(frame: view.bounds)
            view.addSubview(confettiView)
            confettiView.startConfetti()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Constants.progressAnimationDuration + 1.8) {
                self.showReadsCongratulationsAlert(level: .fullGoal)
            }
        }
    }
    
    private func showReadsCongratulationsAlert(level: Level) {
        let alert = UIAlertController.congratulationsAlert(level: level)
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - DetailsViewController Delegate (Updating View)

extension ReadsCountViewController: DetailsViewControllerDelegate {
    
    func updateView() {
        setupUI()
    }
}

//MARK: - MantraSelectionDelegate Delegate

extension ReadsCountViewController: MantraSelectionDelegate {
    func mantraSelected(_ newMantra: Mantra?) {
        mantra = newMantra
    }
}
