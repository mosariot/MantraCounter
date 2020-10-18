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
                identifier: K.detailsViewControllerID,
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
        if let imageData = mantra.image {
            mantraImage.image = UIImage(data: imageData)
        } else {
            mantraImage.image = UIImage(named: K.defaultImage)
        }
        
        titleLabel.text = mantra.title
        titleLabel.font = UIFont.preferredFont(for: .largeTitle, weight: .medium)
        titleLabel.adjustsFontForContentSizeCategory = true
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
        showUpdatingAlert(updatingType: .properValue)
    }
    
    private func showUpdatingAlert(updatingType: UpdatingType) {
        
        let (alertTitle, actionTitle) = alertAndActionTitles(for: updatingType)
        
        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        let positiveAction = UIAlertAction(title: actionTitle, style: .cancel) { [weak self] (action) in
            self?.handleAlertPositiveAction(from: alert, for: updatingType)
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
    
    private func handleAlertPositiveAction(from alert: UIAlertController, for updatingType: UpdatingType) {
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
        case .properValue:
            mantra.reads = value
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
            let confetti = ConfettiView()
            let confettiView = confetti.makeConfettiView(with: view.bounds.size.width)
            view.addSubview(confettiView)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.7) {
                confettiView.removeFromSuperview()
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
