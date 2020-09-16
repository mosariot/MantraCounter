//
//  ReadsCountViewController.swift
//  ReadTheMantra
//
//  Created by Александр Воробьев on 30.07.2020.
//  Copyright © 2020 Александр Воробьев. All rights reserved.
//

import UIKit

class ReadsCountViewController: UIViewController {
    
    private let mantra: Mantra
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet private weak var mantraImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var addRoundsButton: UIButton!
    @IBOutlet private weak var addReadingsButton: UIButton!
    @IBOutlet private weak var manualCorrectionButton: UIButton!
    @IBOutlet private weak var circularProgressBar: CircularProgressBar!
    
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
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(infoButtonPressed), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
        
        setButtonsTitles()
        
        circularProgressBar.currentValue = Int(mantra.reads)
        
        updateUI()
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
    
    //MARK: - Update UI
    
    private func updateUI() {
        if let imageData = mantra.image {
            mantraImage.image = UIImage(data: imageData)
        } else {
            mantraImage.image = UIImage(named: K.defaultImage)
        }
        
        titleLabel.text = mantra.title
        
        circularProgressBar.setValue(to: Int(mantra.reads))
    }
    
    //MARK: - Updating Reads Count
    
    @IBAction func addRoundsPressed(_ sender: UIButton) {
        showUpdatingAlert(updatingType: .rounds)
    }
    
    @IBAction func addReadsPressed(_ sender: UIButton) {
        showUpdatingAlert(updatingType: .readings)
    }
    
    @IBAction func manualCorrrectionPressed(_ sender: UIButton) {
        showUpdatingAlert(updatingType: .manualCorrection)
    }
    
    private func showUpdatingAlert(updatingType: UpdatingType) {
        let alertTitle: String
        let actionTitle: String
        switch updatingType {
        case .rounds:
            alertTitle = NSLocalizedString("Enter Rounds Number", comment: "Alert Title on ReadsCountViewController")
            actionTitle = NSLocalizedString("Add", comment: "Alert Button on ReadsCountViewController")
        case .readings:
            alertTitle = NSLocalizedString("Enter Readings Number", comment: "Alert Title on ReadsCountViewController")
            actionTitle = NSLocalizedString("Add", comment: "Alert Button on ReadsCountViewController")
        case .manualCorrection:
            alertTitle = NSLocalizedString("Enter a New Readings Count", comment: "Alert Title on ReadsCountViewController")
            actionTitle = NSLocalizedString("Done", comment: "Alert Button on ReadsCountViewController")
        }
        
        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        let addAction = UIAlertAction(title: actionTitle, style: .cancel) { [weak self] (action) in
            self?.updateReadsCount(from: alert, with: updatingType)
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = NSLocalizedString("Enter number", comment: "Alert Placehonder on ReadsCountViewController")
            alertTextField.keyboardType = .numberPad
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert Button on ReadsCountViewController"),
                                         style: .default,
                                         handler: nil)
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func updateReadsCount(from alert: UIAlertController, with updatingType: UpdatingType) {
        let oldReads = mantra.reads
        if let alertTextField = alert.textFields?.first?.text {
            if let alertNumber = Int32(alertTextField) {
                switch updatingType {
                case .rounds:
                    mantra.reads += alertNumber * 108
                case .readings:
                    mantra.reads += alertNumber
                case .manualCorrection:
                    mantra.reads = alertNumber
                }
                saveMantras()
                readsCongratulationsCheck(oldReads: oldReads, newReads: mantra.reads)
                updateUI()
            } else {
                showIncorrectDataAlert(updatingType: updatingType)
            }
        }
    }
    
    private func readsCongratulationsCheck(oldReads: Int32, newReads: Int32) {
        if oldReads < K.firstLevel && K.firstLevel...K.secondLevel-1 ~= newReads {
            readsCongratulationsAlert(stage: .first)
        }
        if oldReads < K.secondLevel && newReads >= K.secondLevel {
            readsCongratulationsAlert(stage: .second)
        }
    }
    
    private func readsCongratulationsAlert(stage: Stage) {
        switch stage {
        case .first:
            let alert = UIAlertController(title: NSLocalizedString("Congratulations! You've reached 40 000 reads!", comment: "Alert Title on ReadsCountViewController"),
                                          message: nil,
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        case .second:
            let alert = UIAlertController(title: NSLocalizedString("Congratulations! You've reached 100 000 reads!", comment: "Alert Title on ReadsCountViewController"),
                                          message: nil,
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
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
    
    private func setButtonsTitles() {
        
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
        manualCorrectionButtonString.append(NSAttributedString(string: NSLocalizedString(" Set value",
                                                                                         comment: "Button Title on ReadsCountViewController")))
        manualCorrectionButton.setAttributedTitle(manualCorrectionButtonString, for: .normal)
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
        updateUI()
    }
}

//MARK: - Updating Type

extension ReadsCountViewController {
    
    enum UpdatingType {
        case rounds
        case readings
        case manualCorrection
    }
}

//MARK: - Stage Type

extension ReadsCountViewController {
    
    enum Stage {
        case first
        case second
    }
}

