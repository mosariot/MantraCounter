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
    private let formatter = NumberFormatter()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var mantraImage: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var readsLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var addRoundsButton: UIButton!
    @IBOutlet weak var addReadingsButton: UIButton!
    @IBOutlet weak var manualCorrectionButton: UIButton!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
                                                
    init?(mantra: Mantra, coder: NSCoder) {
        self.mantra = mantra
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(infoButtonPressed), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
        
        mantraImage.isUserInteractionEnabled = false
        setButtonsTitles()
        
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
    }
    
    @objc func infoButtonPressed() {
        guard let detailsViewController = storyboard?.instantiateViewController(
            identifier: "DetailsViewController",
            creator: { coder in
                DetailsViewController(mantra: self.mantra, mode: .view, position: Int(self.mantra.position), coder: coder)
        }) else { return }
        navigationController?.pushViewController(detailsViewController, animated: true)
    }
    
    //MARK: - Update UI
    
    private func updateUI() {
        if let imageData = mantra.image {
            mantraImage.setImage(UIImage(data: imageData), for: .normal)
        } else {
            mantraImage.setImage(UIImage(named: "default_160"), for: .normal)
        }
        
        titleLabel.text = mantra.title
        formatter.groupingSeparator = " "
        formatter.numberStyle = .decimal
        let formattedReads = formatter.string(from: NSNumber(value: mantra.reads))
        readsLabel.text = formattedReads
        progressView.progress = Float(mantra.reads) / Float(100_000)
        
        setReadsLabelColor()
    }
    
    //MARK: - Action Methods
    
    @IBAction func addRoundsPressed(_ sender: UIButton) {
        updatingAlert(updatingType: .rounds)
    }
    
    @IBAction func addReadsPressed(_ sender: UIButton) {
        updatingAlert(updatingType: .readings)
    }
    
    @IBAction func manualCorrrectionPressed(_ sender: UIButton) {
        updatingAlert(updatingType: .manualCorrection)
    }
    
    private func updatingAlert(updatingType: UpdatingType) {
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
        
        let alert = UIAlertController(title: alertTitle, message: "", preferredStyle: .alert)
        let addAction = UIAlertAction(title: actionTitle, style: .default) { [weak self] (action) in
            self?.updateReadsCount(from: alert, with: updatingType)
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = NSLocalizedString("Enter number", comment: "Alert Placehonder on ReadsCountViewController")
            alertTextField.keyboardType = .numberPad
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert Button on ReadsCountViewController"),
                                         style: .cancel,
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
                updateUI()
                readsCongratulationsCheck(oldReads: oldReads, newReads: mantra.reads)
            } else {
                incorrectData()
            }
        }
    }
    
    private func readsCongratulationsCheck(oldReads: Int32, newReads: Int32) {
        if oldReads < 40_000 && (40_000...99_999) ~= newReads {
            readsCongratulationsAlert(stage: .fourty)
        }
        if oldReads < 100_000 && newReads >= 100_000 {
            readsCongratulationsAlert(stage: .hundred)
        }
    }
    
    private func readsCongratulationsAlert(stage: Stage) {
        switch stage {
        case .fourty:
            let alert = UIAlertController(title: NSLocalizedString("Congratulations! You've reached 40 000 reads!", comment: "Alert Title on ReadsCountViewController"),
                                          message: "",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        case .hundred:
            let alert = UIAlertController(title: NSLocalizedString("Congratulations! You've reached 100 000 reads!", comment: "Alert Title on ReadsCountViewController"),
                                          message: "",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func incorrectData() {
        let alert = UIAlertController(title: NSLocalizedString("Please add a valid number", comment: "Alert Title on ReadsCountViewController"),
                                      message: "",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manipulation
    
    private func saveMantras() {
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
    }
    
    //MARK: - Supportive Methods
    
    private func setButtonsTitles() {
        let roundsImageAttachment = NSTextAttachment()
        roundsImageAttachment.image = UIImage(systemName: "goforward")
        let roundsButtonString = NSMutableAttributedString(string: "")
        roundsButtonString.append(NSAttributedString(attachment: roundsImageAttachment))
        roundsButtonString.append(NSAttributedString(string: NSLocalizedString("Add Rounds",
                                                                               comment: "Button Title on ReadsCountViewController")))
        addRoundsButton.setAttributedTitle(roundsButtonString, for: .normal)
        
        let readingsImageAttachment = NSTextAttachment()
        readingsImageAttachment.image = UIImage(systemName: "plus.circle")
        let readingsButtonString = NSMutableAttributedString(string: "")
        readingsButtonString.append(NSAttributedString(attachment: readingsImageAttachment))
        readingsButtonString.append(NSAttributedString(string: NSLocalizedString("Add Readings",
                                                                                 comment: "Button Title on ReadsCountViewController")))
        addReadingsButton.setAttributedTitle(readingsButtonString, for: .normal)
        
        let manualCorrectionImageAttachment = NSTextAttachment()
        manualCorrectionImageAttachment.image = UIImage(systemName: "hand.draw")
        let manualCorrectionButtonString = NSMutableAttributedString(string: "")
        manualCorrectionButtonString.append(NSAttributedString(attachment: manualCorrectionImageAttachment))
        manualCorrectionButtonString.append(NSAttributedString(string: NSLocalizedString("Manual Correction",
                                                                                         comment: "Button Title on ReadsCountViewController")))
        manualCorrectionButton.setAttributedTitle(manualCorrectionButtonString, for: .normal)
    }
    
    private func setReadsLabelColor() {
        var color = UIColor()
        switch mantra.reads {
        case 0...39999:
            color = UIColor.label
        case 40000...99999:
            color = UIColor.systemOrange
        case 100_000...:
            color = UIColor.systemPurple
        default:
            break
        }
        readsLabel.textColor = color
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
        case fourty
        case hundred
    }
}
