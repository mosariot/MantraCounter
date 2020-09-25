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
        let infoButtonItem = UIBarButtonItem(customView: infoButton)
        
        let star = mantra.isFavorite ? "star.fill" : "star"
        let favoriteButtonItem = UIBarButtonItem(image: UIImage(systemName: star), style: .plain, target: self, action: #selector(favoriteButtonPressed))
        
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
        if (oldReads < mantra.readsGoal/2 && mantra.readsGoal/2..<mantra.readsGoal ~= newReads) {
            showReadsCongratulationsAlert(level: .halfGoal)
        }
        if oldReads < mantra.readsGoal && newReads >= mantra.readsGoal {
            let confettiView = makeConfettiView(with: view.bounds.size.width)
            view.addSubview(confettiView)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
                confettiView.removeFromSuperView()
                showReadsCongratulationsAlert(level: .fullGoal)
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


extension ReadsCountViewController {
    func makeConfettiView(with width: Double) -> UIView {

        let view = UIView()
        view.backgroundColor = .clearColor
        view.frame = CGRect(x: 0, y: 0, width: width, height: width)
        
        // Step 1: Creating Confetti Images
        class ConfettiType {
            let color: UIColor
            let shape: ConfettiShape
            let position: ConfettiPosition
            
            init(color: UIColor, shape: ConfettiShape, position: ConfettiPosition) {
                self.color = color
                self.shape = shape
                self.position = position
            }
            
            lazy var name = UUID().uuidString
            
            lazy var image: UIImage = {
                let imageRect: CGRect = {
                    switch shape {
                    case .rectangle:
                        return CGRect(x: 0, y: 0, width: 20, height: 13)
                    case .circle:
                        return CGRect(x: 0, y: 0, width: 10, height: 10)
                    }
                }()
                
                UIGraphicsBeginImageContext(imageRect.size)
                let context = UIGraphicsGetCurrentContext()!
                context.setFillColor(color.cgColor)
                
                switch shape {
                case .rectangle:
                    context.fill(imageRect)
                case .circle:
                    context.fillEllipse(in: imageRect)
                }
                
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return image!
            }()
        }
        
        enum ConfettiShape {
            case rectangle
            case circle
        }
        
        enum ConfettiPosition {
            case foreground
            case background
        }
        
        let confettiTypes: [ConfettiType] = {
            let confettiColors = [
                (r:149,g:58,b:255), (r:255,g:195,b:41), (r:255,g:101,b:26),
                (r:123,g:92,b:255), (r:76,g:126,b:255), (r:71,g:192,b:255),
                (r:255,g:47,b:39), (r:255,g:91,b:134), (r:233,g:122,b:208)
            ].map { UIColor(red: $0.r / 255.0, green: $0.g / 255.0, blue: $0.b / 255.0, alpha: 1) }
            
            // For each position x shape x color, construct an image
            return [ConfettiPosition.foreground, ConfettiPosition.background].flatMap { position in
                return [ConfettiShape.rectangle, ConfettiShape.circle].flatMap { shape in
                    return confettiColors.map { color in
                        return ConfettiType(color: color, shape: shape, position: position)
                    }
                }
            }
        }()
        
        // Step 2: Basic Emitter Layer Setup
        func createConfettiCells() -> [CAEmitterCell] {
            return confettiTypes.map { confettiType in
                let cell = CAEmitterCell()
                cell.name = confettiType.name
                
                cell.beginTime = 0.1
                cell.birthRate = 100
                cell.contents = confettiType.image.cgImage
                cell.emissionRange = CGFloat(Double.pi)
                cell.lifetime = 10
                cell.spin = 4
                cell.spinRange = 8
                cell.velocityRange = 0
                cell.yAcceleration = 0
                
                // Step 3: A _New_ Spin On Things
                
                cell.setValue("plane", forKey: "particleType")
                cell.setValue(Double.pi, forKey: "orientationRange")
                cell.setValue(Double.pi / 2, forKey: "orientationLongitude")
                cell.setValue(Double.pi / 2, forKey: "orientationLatitude")
                
                return cell
            }
        }
        
        // Step 4: _Wave_ Hello to CAEmitterBehavior

        func createBehavior(type: String) -> NSObject {
            let behaviorClass = NSClassFromString("CAEmitterBehavior") as! NSObject.Type
            let behaviorWithType = behaviorClass.method(for: NSSelectorFromString("behaviorWithType:"))!
            let castedBehaviorWithType = unsafeBitCast(behaviorWithType, to:(@convention(c)(Any?, Selector, Any?) -> NSObject).self)
            return castedBehaviorWithType(behaviorClass, NSSelectorFromString("behaviorWithType:"), type)
        }
        
        func horizontalWaveBehavior() -> Any {
            let behavior = createBehavior(type: "wave")
            behavior.setValue([100, 0, 0], forKeyPath: "force")
            behavior.setValue(0.5, forKeyPath: "frequency")
            return behavior
        }
        
        func verticalWaveBehavior() -> Any {
            let behavior = createBehavior(type: "wave")
            behavior.setValue([0, 500, 0], forKeyPath: "force")
            behavior.setValue(3, forKeyPath: "frequency")
            return behavior
        }
        
        // Step 5: More _Attractive_ Confetti
        func attractorBehavior(for emitterLayer: CAEmitterLayer) -> Any {
            let behavior = createBehavior(type: "attractor")
            behavior.setValue("attractor", forKeyPath: "name")
            
            // Attractiveness
            behavior.setValue(-290, forKeyPath: "falloff")
            behavior.setValue(300, forKeyPath: "radius")
            behavior.setValue(10, forKeyPath: "stiffness")
            
            // Position
            behavior.setValue(CGPoint(x: emitterLayer.emitterPosition.x,
                                      y: emitterLayer.emitterPosition.y + 20),
                              forKeyPath: "position")
            behavior.setValue(-70, forKeyPath: "zPosition")
            
            return behavior
        }
        
        func addBehaviors(to layer: CAEmitterLayer) {
            layer.setValue([
                horizontalWaveBehavior(),
                verticalWaveBehavior(),
                attractorBehavior(for: layer)
            ], forKey: "emitterBehaviors")
        }
        
        // Step 6: Animations & Explosions
        
        func addAttractorAnimation(to layer: CALayer) {
            let animation = CAKeyframeAnimation()
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            animation.duration = 3
            animation.keyTimes = [0, 0.4]
            animation.values = [80, 5]
            
            layer.add(animation, forKey: "emitterBehaviors.attractor.stiffness")
        }
        
        func addBirthrateAnimation(to layer: CALayer) {
            let animation = CABasicAnimation()
            animation.duration = 1
            animation.fromValue = 1
            animation.toValue = 0
            
            layer.add(animation, forKey: "birthRate")
        }
        
        func addAnimations(to layer: CAEmitterLayer) {
            addAttractorAnimation(to: layer)
            addBirthrateAnimation(to: layer)
            addGravityAnimation(to: layer)
        }
        
        // Step 7: Air Resistance & Gravity
        
        func dragBehavior() -> Any {
            let behavior = createBehavior(type: "drag")
            behavior.setValue("drag", forKey: "name")
            behavior.setValue(2, forKey: "drag")
            
            return behavior
        }
        
        func addDragAnimation(to layer: CALayer) {
            let animation = CABasicAnimation()
            animation.duration = 0.35
            animation.fromValue = 0
            animation.toValue = 2
            
            layer.add(animation, forKey:  "emitterBehaviors.drag.drag")
        }
        
        func addGravityAnimation(to layer: CALayer) {
            let animation = CAKeyframeAnimation()
            animation.duration = 6
            animation.keyTimes = [0.05, 0.1, 0.5, 1]
            animation.values = [0, 100, 2000, 4000]
            
            for image in confettiTypes {
                layer.add(animation, forKey: "emitterCells.\(image.name).yAcceleration")
            }
        }
        
        // Step 8: Background & Foreground
        
        func createConfettiLayer() -> CAEmitterLayer {
            let emitterLayer = CAEmitterLayer()
            
            emitterLayer.birthRate = 0
            emitterLayer.emitterCells = createConfettiCells()
            emitterLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.minY - 100)
            emitterLayer.emitterSize = CGSize(width: 100, height: 100)
            emitterLayer.emitterShape = .sphere
            emitterLayer.frame = view.bounds
            
            emitterLayer.beginTime = CACurrentMediaTime()
            return emitterLayer
        }
        
        var foregroundConfettiLayer = createConfettiLayer()
        
        var backgroundConfettiLayer: CAEmitterLayer = {
            let emitterLayer = createConfettiLayer()
            
            for emitterCell in emitterLayer.emitterCells ?? [] {
                emitterCell.scale = 0.5
            }
            
            emitterLayer.opacity = 0.5
            emitterLayer.speed = 0.95
            
            return emitterLayer
        }()
        
        // And finally...
        for layer in [foregroundConfettiLayer, backgroundConfettiLayer] {
            view.layer.addSublayer(layer)
            addBehaviors(to: layer)
            addAnimations(to: layer)
        }
        return view
    }
}
