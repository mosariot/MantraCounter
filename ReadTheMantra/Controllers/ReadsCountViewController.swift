//
//  ReadsCountViewController.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 30.07.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

protocol ReadsCountViewControllerDelegate: class {
    func favoriteActionPerformed()
    func updateWidget()
}

final class ReadsCountViewController: UIViewController {
    
    //MARK: - Properties
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private let mantra: Mantra
    private let positionFavorite: Int32
    private weak var delegate: ReadsCountViewControllerDelegate?
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var portraitMantraImageView: UIImageView!
    @IBOutlet private weak var landscapeMantraImageView: UIImageView!
    @IBOutlet private weak var titleLabel: CopyableLabel!
    @IBOutlet private weak var addRoundsButton: AdjustReadsButton!
    @IBOutlet private weak var addReadsButton: AdjustReadsButton!
    @IBOutlet private weak var setProperValueButton: AdjustReadsButton!
    @IBOutlet private weak var circularProgressView: CircularProgressView!
    @IBOutlet private weak var readsGoalButton: UIButton!
    
    //MARK: - Init
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init?(mantra: Mantra,
          positionFavorite: Int32,
          delegate: ReadsCountViewControllerDelegate,
          coder: NSCoder) {
        self.mantra = mantra
        self.positionFavorite = positionFavorite
        self.delegate = delegate
        
        super.init(coder: coder)
    }
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        setupNavButtons()
        
        circularProgressView.goal = Int(mantra.readsGoal)
        circularProgressView.value = Int(mantra.reads)
        
        setupUI()
    }
    
    private func setupNavButtons() {
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
        guard let detailsViewController = storyboard?.instantiateViewController(
                identifier: Constants.detailsViewControllerID,
                creator: { [weak self] coder in
                    guard let self = self else { fatalError() }
                    return DetailsViewController(mantra: self.mantra,
                                                 mode: .view,
                                                 position: Int(self.mantra.position),
                                                 delegate: self, coder: coder)
                }) else { return }
        let navigationController = UINavigationController(rootViewController: detailsViewController)
        present(navigationController, animated: true)
    }
    
    private func favoriteButtonPressed() {
        mantra.isFavorite = !mantra.isFavorite
        mantra.positionFavorite = mantra.isFavorite ? positionFavorite : 0
        delegate?.favoriteActionPerformed()
        delegate?.updateWidget()
        saveMantras()
        setupNavButtons()
    }
    
    //MARK: - Setup UI
    
    private func setupUI() {
        portraitMantraImageView.image = (mantra.image != nil) ? UIImage(data: mantra.image!) : UIImage(named: Constants.defaultImage)
        landscapeMantraImageView.image = (mantra.image != nil) ? UIImage(data: mantra.image!) : UIImage(named: Constants.defaultImage)
        titleLabel.text = mantra.title
        titleLabel.font = UIFont.preferredFont(for: .largeTitle, weight: .medium)
        titleLabel.adjustsFontForContentSizeCategory = true
        readsGoalButton.setTitle(NSLocalizedString("Goal: ", comment: "Button on ReadsCountViewController") + Int(mantra.readsGoal).stringFormattedWithSpaces(), for: .normal)
        animateCircularProgressViewForUpdatedValues()
        
        let standardAppearance = UINavigationBarAppearance()
        let compactAppearance = UINavigationBarAppearance()
        standardAppearance.titleTextAttributes = [.foregroundColor: UIColor.clear]
        compactAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        navigationItem.standardAppearance = standardAppearance
        navigationItem.compactAppearance = compactAppearance
        navigationItem.title = mantra.title
        
        addReadsButton.imageSystemName = "plus.circle"
        addRoundsButton.imageSystemName = "goforward.plus"
        setProperValueButton.imageSystemName = "hand.draw"
    }
    
    private func animateCircularProgressViewForUpdatedValues() {
        circularProgressView.setGoalAnimation(to: Int(mantra.readsGoal))
        circularProgressView.setValueAnimation(to: Int(mantra.reads))
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
        
        var value: Int32 = 0
        let (alertTitle, actionTitle) = alertAndActionTitles(for: updatingType)
        
        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        let positiveAction = UIAlertAction(title: actionTitle, style: .default) { [weak self] action in
            guard let self = self else { return }
            self.handleAlertPositiveAction(forValue: value, updatingType: updatingType)
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = NSLocalizedString("Enter number", comment: "Alert Placehonder on ReadsCountViewController")
            alertTextField.keyboardType = .numberPad
            positiveAction.isEnabled = false
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alertTextField, queue: .main) { [weak self] notification in
                guard let self = self else { return }
                if self.isValidUpdatingNumber(text: alertTextField.text, updatingType: updatingType) {
                    positiveAction.isEnabled = true
                    guard
                        let textValue = alertTextField.text,
                        let numberValue = Int32(textValue)
                    else { return }
                    value = numberValue
                } else {
                    positiveAction.isEnabled = false
                }
            }
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert Button on ReadsCountViewController"),
                                         style: .default,
                                         handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(positiveAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func isValidUpdatingNumber(text: String?, updatingType: UpdatingType) -> Bool {
        guard
            let alertText = text,
            let alertNumber = UInt32(alertText)
        else { return false }
        
        switch updatingType {
        case .goal, .properValue:
            return 0...1_000_000 ~= alertNumber
        case .reads:
            return 0...1_000_000 ~= UInt32(mantra.reads) + alertNumber
        case .rounds:
            return 0...1_000_000 ~= UInt32(mantra.reads) + alertNumber * 108
        }
    }
    
    private func alertAndActionTitles(for updatingType: UpdatingType) -> (String, String) {
        switch updatingType {
        case .goal:
            return (NSLocalizedString("Set a New Readings Goal", comment: "Alert Title on ReadsCountViewController"),
                    NSLocalizedString("Set", comment: "Alert Button on ReadsCountViewController"))
        case .rounds:
            return (NSLocalizedString("Enter Rounds Number", comment: "Alert Title on ReadsCountViewController"),
                    NSLocalizedString("Add", comment: "Alert Button on ReadsCountViewController"))
        case .reads:
            return (NSLocalizedString("Enter Readings Number", comment: "Alert Title on ReadsCountViewController"),
                    NSLocalizedString("Add", comment: "Alert Button on ReadsCountViewController"))
        case .properValue:
            return (NSLocalizedString("Set a New Readings Count", comment: "Alert Title on ReadsCountViewController"),
                    NSLocalizedString("Set", comment: "Alert Button on ReadsCountViewController"))
        }
    }
    
    private func handleAlertPositiveAction(forValue value: Int32, updatingType: UpdatingType) {
        let oldReads = mantra.reads
        updateValues(with: value, updatingType: updatingType)
        updateProrgessView(for: updatingType)
        readsGoalButton.setTitle(NSLocalizedString("Goal: ", comment: "Button on ReadsCountViewController") + Int(mantra.readsGoal).stringFormattedWithSpaces(), for: .normal)
        saveMantras()
        delegate?.updateWidget()
        readsCongratulationsCheck(oldReads: oldReads, newReads: mantra.reads)
    }
    
    private func updateValues(with value: Int32, updatingType: UpdatingType) {
        switch updatingType {
        case .goal:
            mantra.readsGoal = value
        case .reads:
            mantra.reads += value
        case .rounds:
            mantra.reads += value * 108
        case .properValue:
            mantra.reads = value
        }
    }
    
    private func updateProrgessView(for updatingType: UpdatingType) {
        switch updatingType {
        case .goal:
            circularProgressView.setGoalAnimation(to: Int(mantra.readsGoal))
        case .reads, .rounds, .properValue:
            circularProgressView.setValueAnimation(to: Int(mantra.reads))
        }
    }
    
    private func readsCongratulationsCheck(oldReads: Int32, newReads: Int32) {
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
        let alert = UIAlertController(title: congratulationsAlertTitle(for: level),
                                      message: nil,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func congratulationsAlertTitle(for level: Level) -> String {
        switch level {
        case .halfGoal:
            return NSLocalizedString("Congratulations! You're half way to your goal!", comment: "Alert Title on ReadsCountViewController")
        case .fullGoal:
            return NSLocalizedString("Congratulations! You've reached your goal!", comment: "Alert Title on ReadsCountViewController")
        }
    }
}

//MARK: - Model Manipulation

extension ReadsCountViewController {
    
    private func saveMantras() {
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
    }
}

//MARK: - DetailsViewController Delegate (Updating View and Widget)

extension ReadsCountViewController: DetailsViewControllerDelegate {
    
    func updateViewAndWidget() {
        setupUI()
        delegate?.updateWidget()
    }
}

//MARK: - Updating Type

extension ReadsCountViewController {
    
    enum UpdatingType {
        case goal
        case reads
        case rounds
        case properValue
    }
}

//MARK: - Level Type

extension ReadsCountViewController {
    
    enum Level {
        case halfGoal
        case fullGoal
    }
}
