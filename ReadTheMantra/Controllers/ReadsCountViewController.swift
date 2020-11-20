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
    private let positionFavorite: Int32
    
    @IBOutlet private weak var mantraImageView: UIImageView!
    @IBOutlet private weak var landscapeMantraImageView: UIImageView!
    @IBOutlet private weak var titleLabel: CopyableLabel!
    @IBOutlet private weak var addRoundsButton: UIButton!
    @IBOutlet private weak var addReadingsButton: UIButton!
    @IBOutlet private weak var setProperValueButton: UIButton!
    @IBOutlet private weak var circularProgressView: CircularProgressView!
    @IBOutlet private weak var readsGoalButton: UIButton!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init?(mantra: Mantra, positionFavorite: Int32, coder: NSCoder) {
        self.mantra = mantra
        self.positionFavorite = positionFavorite
        
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
        let infoButtonItem = UIBarButtonItem(customView: infoButton)
                
        let star = mantra.isFavorite ? "star.fill" : "star"
        let favoriteButtonItem = UIBarButtonItem(image: UIImage(systemName: star),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(favoriteButtonPressed))
        
        navigationItem.rightBarButtonItems = [infoButtonItem, favoriteButtonItem]
    }
    
    @objc private func infoButtonPressed() {
        guard let detailsViewController = storyboard?.instantiateViewController(
                identifier: Constants.detailsViewControllerID,
                creator: { [weak self] coder in
                    guard let self = self else { fatalError() }
                    return DetailsViewController(mantra: self.mantra, mode: .view, position: Int(self.mantra.position), delegate: self, coder: coder)
                }) else { return }
        let navigationController = UINavigationController(rootViewController: detailsViewController)
        present(navigationController, animated: true)
    }
    
    @objc private func favoriteButtonPressed() {
        mantra.isFavorite = !mantra.isFavorite
        mantra.positionFavorite = mantra.isFavorite ? positionFavorite : 0
        saveMantras()
        setupNavButtons()
    }
    
    //MARK: - Setup UI
    
    private func setupUI() {
        
        mantraImageView.image = (mantra.image != nil) ? UIImage(data: mantra.image!) : UIImage(named: Constants.defaultImage)
        landscapeMantraImageView.image = (mantra.image != nil) ? UIImage(data: mantra.image!) : UIImage(named: Constants.defaultImage)
        titleLabel.text = mantra.title
        titleLabel.font = UIFont.preferredFont(for: .largeTitle, weight: .medium)
        titleLabel.adjustsFontForContentSizeCategory = true
        readsGoalButton.setTitle(NSLocalizedString("Goal: ", comment: "Button on ReadsCountViewController") + Int(mantra.readsGoal).stringFormattedWithSpaces(), for: .normal)
        circularProgressView.setValue(to: Int(mantra.reads))
        
        let standartAppearance = UINavigationBarAppearance()
        let compactAppearance = UINavigationBarAppearance()
        standartAppearance.titleTextAttributes = [.foregroundColor: UIColor.clear]
        compactAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        navigationItem.standardAppearance = standartAppearance
        navigationItem.compactAppearance = compactAppearance
        navigationItem.title = mantra.title
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
        let positiveAction = UIAlertAction(title: actionTitle, style: .default) { [weak self] (action) in
            self?.handleAlertPositiveAction(forValue: value, updatingType: updatingType)
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = NSLocalizedString("Enter number", comment: "Alert Placehonder on ReadsCountViewController")
            alertTextField.keyboardType = .numberPad
            positiveAction.isEnabled = false
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alertTextField, queue: .main) { [weak self] (notification) in
                if let isValidUpdatingNumber = self?.isValidUpdatingNumber(text: alertTextField.text, updatingType: updatingType), isValidUpdatingNumber {
                    positiveAction.isEnabled = true
                    if let textValue = alertTextField.text, let numberValue = Int32(textValue) {
                        value = numberValue
                    }
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
        guard let alertText = text, let alertNumber = UInt32(alertText) else { return false }
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
            return (NSLocalizedString("Set new readings goal", comment: "Alert Title on ReadsCountViewController"),
                    NSLocalizedString("Set", comment: "Alert Button on ReadsCountViewController"))
        case .rounds:
            return (NSLocalizedString("Enter Rounds Number", comment: "Alert Title on ReadsCountViewController"),
                    NSLocalizedString("Add", comment: "Alert Button on ReadsCountViewController"))
        case .reads:
            return (NSLocalizedString("Enter Readings Number", comment: "Alert Title on ReadsCountViewController"),
                    NSLocalizedString("Add", comment: "Alert Button on ReadsCountViewController"))
        case .properValue:
            return (NSLocalizedString("Enter a New Readings Count", comment: "Alert Title on ReadsCountViewController"),
                    NSLocalizedString("Set", comment: "Alert Button on ReadsCountViewController"))
        }
    }
    
    private func handleAlertPositiveAction(forValue value: Int32, updatingType: UpdatingType) {
        let oldReads = mantra.reads
        updateValues(with: value, updatingType: updatingType)
        lockOrientation()
        updateProrgessView(for: updatingType)
        unlockOrientation()
        saveMantras()
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
    
    private func lockOrientation() {
        if let currentOrientation = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation {
            switch currentOrientation {
            case .landscapeLeft:
                Orientation.lock(.landscapeLeft)
            case .landscapeRight:
                Orientation.lock(.landscapeRight)
            case .portrait:
                Orientation.lock(.portrait)
            case .portraitUpsideDown:
                Orientation.lock(.portraitUpsideDown)
            default:
                return
            }
        }
    }
    
    private func unlockOrientation() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            Orientation.lock(.all)
        }
    }
    
    private func updateProrgessView(for updatingType: UpdatingType) {
        switch updatingType {
        case .goal:
            circularProgressView.setGoal(to: Int(mantra.readsGoal))
            readsGoalButton.setTitle(NSLocalizedString("Goal: ", comment: "Button on ReadsCountViewController") + Int(mantra.readsGoal).stringFormattedWithSpaces(), for: .normal)
        case .reads, .rounds, .properValue:
            circularProgressView.setValue(to: Int(mantra.reads))
        }
    }
    
    private func readsCongratulationsCheck(oldReads: Int32, newReads: Int32) {
        if (oldReads < mantra.readsGoal/2 && mantra.readsGoal/2..<mantra.readsGoal ~= newReads) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.3) {
                self.showReadsCongratulationsAlert(level: .halfGoal)
            }
        }
        if oldReads < mantra.readsGoal && newReads >= mantra.readsGoal {
            let confettiView = ConfettiView(frame: view.bounds)
            view.addSubview(confettiView)
            confettiView.alpha = 0
            confettiView.startConfetti()
            UIView.animate(withDuration: 0.6) {
                confettiView.alpha = 1
            }
            confettiView.stopConfetti()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.7) {
                self.showReadsCongratulationsAlert(level: .fullGoal)
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.7) {
                confettiView.removeFromSuperview()
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
    
    //MARK: - Buttons Initial Appearance
    
    private func setReadsButtonsTitles() {
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .light, scale: .large)
        
        let largeReadings = UIImage(systemName: "plus.circle", withConfiguration: largeConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        let largeRounds = UIImage(systemName: "goforward.plus", withConfiguration: largeConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        let largeHand = UIImage(systemName: "hand.draw", withConfiguration: largeConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        
        addReadingsButton.setImage(largeReadings, for: .normal)
        addRoundsButton.setImage(largeRounds, for: .normal)
        setProperValueButton.setImage(largeHand, for: .normal)

        addRoundsButton.layer.cornerRadius = 35
        addReadingsButton.layer.cornerRadius = 35
        setProperValueButton.layer.cornerRadius = 35
        
        addRoundsButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        addRoundsButton.layer.shadowOffset = CGSize(width: 3, height: 3)
        addRoundsButton.layer.shadowOpacity = 1.0
        addRoundsButton.layer.shadowRadius = 3.0
        
        addReadingsButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        addReadingsButton.layer.shadowOffset = CGSize(width: 3, height: 3)
        addReadingsButton.layer.shadowOpacity = 1.0
        addReadingsButton.layer.shadowRadius = 3.0
        
        setProperValueButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        setProperValueButton.layer.shadowOffset = CGSize(width: 3, height: 3)
        setProperValueButton.layer.shadowOpacity = 1.0
        setProperValueButton.layer.shadowRadius = 3.0
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
