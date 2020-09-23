//
//  ReadsCountViewController.swift
//  ReadTheMantra
//
//  Created by Александр Воробьев on 30.07.2020.
//  Copyright © 2020 Александр Воробьев. All rights reserved.
//

import UIKit

class ReadsCountViewController: UIViewController {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private let mantra: Mantra
    
    @IBOutlet private weak var mantraImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var addRoundsButton: UIButton!
    @IBOutlet private weak var addReadingsButton: UIButton!
    @IBOutlet private weak var setProperValueButton: UIButton!
    @IBOutlet private weak var circularProgressView: CircularProgressView!
    @IBOutlet private weak var readsGoalButton: UIButton!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init?(mantra: Mantra, coder: NSCoder) {
        self.mantra = mantra
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        setupNavButtons()
        setReadsButtonsTitles()
        
        circularProgressView.currentValue = Int(mantra.reads)
        circularProgressView.readsGoal = Int(mantra.readsGoal)
        
        setupUI()
    }
    
    private func setupNavButtons() {
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(infoButtonPressed), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
    }
    
    @objc private func infoButtonPressed() {
        guard let detailsViewController = storyboard?.instantiateViewController(
                identifier: K.detailsViewControllerID,
                creator: { [weak self] coder in
                    guard let self = self else { fatalError() }
                    return DetailsViewController(mantra: self.mantra, mode: .view, position: Int(self.mantra.position), delegate: self, coder: coder)
                }) else { return }
        let navigationController = UINavigationController(rootViewController: detailsViewController)
        present(navigationController, animated: true)
    }
    
    //MARK: - Setup UI
    
    private func setupUI() {
        if let imageData = mantra.image {
            mantraImage.image = UIImage(data: imageData)
        } else {
            mantraImage.image = UIImage(named: K.defaultImage)
        }
        
        titleLabel.text = mantra.title
        readsGoalButton.setTitle(NSLocalizedString("Goal: ", comment: "Button on ReadsCountViewController") + Int(mantra.readsGoal).stringFormattedWithSpaces(), for: .normal)
        circularProgressView.setValue(to: Int(mantra.reads))
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
        showUpdatingAlert(updatingType: .setProperValue)
    }
    
    private func showUpdatingAlert(updatingType: UpdatingType) {
        
        let (alertTitle, actionTitle) = alertAndActionTitles(with: updatingType)
        
        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        let positiveAction = UIAlertAction(title: actionTitle, style: .cancel) { [weak self] (action) in
            self?.handleAlertPositiveAction(from: alert, with: updatingType)
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = NSLocalizedString("Enter number", comment: "Alert Placehonder on ReadsCountViewController")
            alertTextField.keyboardType = .numberPad
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert Button on ReadsCountViewController"),
                                         style: .default,
                                         handler: nil)
        alert.addAction(positiveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func alertAndActionTitles(with updatingType: UpdatingType) -> (String, String) {
        switch updatingType {
        case .goal:
            return (NSLocalizedString("Set new readings goal", comment: "Alert Title on ReadsCountViewController"),
                    NSLocalizedString("Set", comment: "Alert Button on ReadsCountViewController"))
        case .rounds:
            return (NSLocalizedString("Enter Rounds Number", comment: "Alert Title on ReadsCountViewController"),
                    NSLocalizedString("Add", comment: "Alert Button on ReadsCountViewController"))
        case .reads:
            return (NSLocalizedString("Enter Readings Number", comment: "Alert Title on ReadsCountViewController"),
                    NSLocalizedString("Add", comment: "Alert Button on ReadsCountViewController"))
        case .setProperValue:
            return (NSLocalizedString("Enter a New Readings Count", comment: "Alert Title on ReadsCountViewController"),
                    NSLocalizedString("Set", comment: "Alert Button on ReadsCountViewController"))
        }
    }
    
    private func handleAlertPositiveAction(from alert: UIAlertController, with updatingType: UpdatingType) {
        let oldReads = mantra.reads
        if let alertTextField = alert.textFields?.first?.text {
            if let alertNumber = UInt32(alertTextField) {
                updateValues(with: Int32(alertNumber), updatingType: updatingType)
                updateProrgessView(for: updatingType)
                saveMantras()
                readsCongratulationsCheck(oldReads: oldReads, newReads: mantra.reads)
            } else {
                showIncorrectDataAlert(updatingType: updatingType)
            }
        }
    }
    
    private func updateValues(with value: Int32, updatingType: UpdatingType) {
        switch updatingType {
        case .goal:
            mantra.readsGoal = value
        case .reads:
            mantra.reads += value
        case .rounds:
            mantra.reads += value * 108
        case .setProperValue:
            mantra.reads = value
        }
    }
    
    private func updateProrgessView(for updatingType: UpdatingType) {
        switch updatingType {
        case .goal:
            circularProgressView.setGoal(to: Int(mantra.readsGoal))
            readsGoalButton.setTitle(NSLocalizedString("Goal: ", comment: "Button on ReadsCountViewController") + Int(mantra.readsGoal).stringFormattedWithSpaces(), for: .normal)
        case .reads:
            circularProgressView.setValue(to: Int(mantra.reads))
        case .rounds:
            circularProgressView.setValue(to: Int(mantra.reads))
        case .setProperValue:
            circularProgressView.setValue(to: Int(mantra.reads))
        }
    }
    
    private func readsCongratulationsCheck(oldReads: Int32, newReads: Int32) {
        if (oldReads < mantra.readsGoal/2 && mantra.readsGoal/2...mantra.readsGoal-1 ~= newReads) {
            showReadsCongratulationsAlert(level: .halfGoal)
        }
        if oldReads < mantra.readsGoal && newReads >= mantra.readsGoal {
            showReadsCongratulationsAlert(level: .fullGoal)
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
    
    private func showIncorrectDataAlert(updatingType: UpdatingType) {
        let alert = UIAlertController(title: NSLocalizedString("Please add a valid number", comment: "Alert Title on ReadsCountViewController"),
                                      message: nil,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] (action) in
            self?.showUpdatingAlert(updatingType: updatingType)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Button Initial Appearance
    
    private func setReadsButtonsTitles() {
        
        let readingsImageAttachment = NSTextAttachment()
        readingsImageAttachment.image = UIImage(systemName: "plus.circle")
        let readingsButtonString = NSMutableAttributedString(string: "")
        readingsButtonString.append(NSAttributedString(attachment: readingsImageAttachment))
        readingsButtonString.append(NSAttributedString(string: NSLocalizedString(" Add Readings",
                                                                                 comment: "Button Title on ReadsCountViewController")))
        addReadingsButton.setAttributedTitle(readingsButtonString, for: .normal)
        
        let roundsImageAttachment = NSTextAttachment()
        roundsImageAttachment.image = UIImage(systemName: "goforward")
        let roundsButtonString = NSMutableAttributedString(string: "")
        roundsButtonString.append(NSAttributedString(attachment: roundsImageAttachment))
        roundsButtonString.append(NSAttributedString(string: NSLocalizedString(" Add Rounds (х108)",
                                                                               comment: "Button Title on ReadsCountViewController")))
        addRoundsButton.setAttributedTitle(roundsButtonString, for: .normal)
        
        let manualCorrectionImageAttachment = NSTextAttachment()
        manualCorrectionImageAttachment.image = UIImage(systemName: "hand.draw")
        let manualCorrectionButtonString = NSMutableAttributedString(string: "")
        manualCorrectionButtonString.append(NSAttributedString(attachment: manualCorrectionImageAttachment))
        manualCorrectionButtonString.append(NSAttributedString(string: NSLocalizedString(" Set Proper Value",
                                                                                         comment: "Button Title on ReadsCountViewController")))
        setProperValueButton.setAttributedTitle(manualCorrectionButtonString, for: .normal)
    }
    
    //MARK: - Model Manipulation
    
    private func saveMantras() {
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
    }
}

//MARK: - DetailsViewController Delegate (Updating View)

extension ReadsCountViewController: DetailsViewControllerDelegate {
    
    func updateView() {
        setupUI()
    }
}

//MARK: - Updating Type

extension ReadsCountViewController {
    
    enum UpdatingType {
        case goal
        case reads
        case rounds
        case setProperValue
    }
}

//MARK: - Level Type

extension ReadsCountViewController {
    
    enum Level {
        case halfGoal
        case fullGoal
    }
}
