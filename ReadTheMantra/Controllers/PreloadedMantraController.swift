//
//  PreloadedMantraController.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 07.04.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

final class PreloadedMantraController: UIViewController {
    
    private enum Section {
        case main
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, PreloadedMantra.ID>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, PreloadedMantra.ID>
    
    private var dataSource: DataSource! = nil
    private var collectionView: UICollectionView! = nil
    
    private class PreloadedMantra: Identifiable, Hashable {
        let id = UUID()
        var title: String = ""
        var image: UIImage? = nil
        var isSelected: Bool = false
        
        static func ==(lhs: PreloadedMantra, rhs: PreloadedMantra) -> Bool {
            return lhs.id == rhs.id
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    private let mantraDataManager: DataManager
    private var mantraTitles: [String]
    
    private var preloadedMantras: [PreloadedMantra] = []
    
    private var selectedMantrasTitles: [String] {
        preloadedMantras
            .filter { $0.isSelected }
            .map { $0.title }
    }
    
    private let addHapticGenerator = UINotificationFeedbackGenerator()
    
    init(mantraDataManager: DataManager) {
        self.mantraDataManager = mantraDataManager
        self.mantraTitles = mantraDataManager.fetchedMantras.compactMap { $0.title }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        preloadedMantras = getPreloadedMantras()
        configureHierarchy()
        configureDataSource()
        addHapticGenerator.prepare()
    }
}

//MARK: - UICollectionView Setup

extension PreloadedMantraController {
    
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension PreloadedMantraController {
    
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, PreloadedMantra> { cell, indexPath, mantra in
            var configuration = cell.defaultContentConfiguration()
            configuration.text = mantra.title
            configuration.image = mantra.image
            cell.contentConfiguration = configuration
            
            let checkmark = UIImage(systemName: "checkmark.circle.fill",
                                    withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
            let circle = UIImage(systemName: "circle",
                                 withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
            let badgeConfiguration = UICellAccessory.CustomViewConfiguration(customView: UIImageView(image: mantra.isSelected ? checkmark : circle),
                                                                             placement: .trailing(displayed: .always))
            let badgeAccessory = UICellAccessory.customView(configuration: badgeConfiguration)
            cell.accessories = [badgeAccessory]
        }
        
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, mantraID -> UICollectionViewCell? in
            let mantra = self.preloadedMantras.first(where: { $0.id == mantraID })
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: mantra)
        }
        
        var snapshot = Snapshot()
        let preloadedMantrasIDs = preloadedMantras.map { $0.id }
        snapshot.appendSections([.main])
        snapshot.appendItems(preloadedMantrasIDs)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

//MARK: - UI Methods

extension PreloadedMantraController {
    
    private func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        title = NSLocalizedString("Mantras Choice", comment: "Title of PreloadedMantraController")
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .close,
            primaryAction: UIAction(handler: { [weak self] _ in
                guard let self = self else { return }
                self.dismiss(animated: true, completion: nil)
            }))
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Add", comment: "Button on PreloadedMantraController"),
            primaryAction: UIAction(handler: { [weak self] _ in
                guard let self = self else { return }
                self.addButtonPressed()
            }))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
}

//MARK: - Data Methods

extension PreloadedMantraController {
    
    private func getPreloadedMantras() -> [PreloadedMantra] {
        var mantras: [PreloadedMantra] = []
        PreloadedMantras.sortedData().forEach { data in
            let mantra = PreloadedMantra()
            data.forEach { key, value in
                if key == .title {
                    mantra.title = value
                }
                if key == .image {
                    if let image = UIImage(named: value) {
                        mantra.image = image.resize(to: CGSize(width: Constants.rowHeight/2, height: Constants.rowHeight/2))
                    } else {
                        mantra.image = UIImage(named: Constants.defaultImage)?.resize(to: CGSize(width: Constants.rowHeight/2, height: Constants.rowHeight/2))
                    }
                }
            }
            mantras.append(mantra)
        }
        return mantras
    }
    
    private func addButtonPressed() {
        if isMantraDuplicating() {
            showDuplicatingAlert()
        } else {
            handleAddPreloadedMantra()
        }
        
    }
    
    private func isMantraDuplicating() -> Bool {
        var isDuplicating = false
        mantraTitles.forEach { title in
            if selectedMantrasTitles.contains(where: { $0.caseInsensitiveCompare(title) == .orderedSame }) {
                isDuplicating = true
            }
        }
        return isDuplicating
    }
    
    private func showDuplicatingAlert() {
        let alert = AlertControllerFactory.duplicatingAlertForPreloadedMantras(navigationItem.rightBarButtonItem) { [weak self] in
            guard let self = self else { return }
            self.handleAddPreloadedMantra()
        }
        present(alert, animated: true, completion: nil)
    }
    
    private func handleAddPreloadedMantra() {
        mantraDataManager.addPreloadedMantras(with: selectedMantrasTitles)
        
        addHapticGenerator.notificationOccurred(.success)
        
        HudView.makeViewWithCheckmark(
            inView: navigationController?.view ?? view,
            withText: NSLocalizedString("Added", comment: "HUD title"))
        afterDelay(0.8) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

//MARK: - UICollectionViewDelegate

extension PreloadedMantraController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let mantraID = dataSource.itemIdentifier(for: indexPath),
        let mantra = preloadedMantras.first(where: { $0.id == mantraID })
        else { return }
        collectionView.deselectItem(at: indexPath, animated: true)
        mantra.isSelected.toggle()
        navigationItem.rightBarButtonItem?.isEnabled = !preloadedMantras.filter { $0.isSelected }.isEmpty
        
        var newSnapshot = dataSource.snapshot()
        
        if ProcessInfo.processInfo.isiOSAppOnMac || ProcessInfo.processInfo.isMacCatalystApp {
            newSnapshot.reloadItems([mantra.id])
        } else {
            if #available(iOS 15, *) {
                newSnapshot.reconfigureItems([mantra.id])
            } else {
                newSnapshot.reloadItems([mantra.id])
            }
        }
        dataSource.apply(newSnapshot)
    }
}
