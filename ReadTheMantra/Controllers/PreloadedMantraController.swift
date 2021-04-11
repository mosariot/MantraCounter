//
//  PreloadedMantraController.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 07.04.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

final class PreloadedMantraController: UIViewController {
    
    var mantraTitles: [String] = []
    
    private enum Section {
        case main
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, PreloadedMantra>! = nil
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
    
    private let dataProvider = MantraProvider()
    
    private var preloadedMantras: [PreloadedMantra] = []
    
    private lazy var sortedInitialMantraData = InitialMantra.sortedData()
    private var selectedMantrasTitles: [String] {
        preloadedMantras.filter{ $0.isSelected }.map{ $0.title }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        preloadedMantras = getPreloadedMantras()
        configureHierarchy()
        configureDataSource()
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
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, PreloadedMantra> { (cell, indexPath, mantra) in
            var configuration = cell.defaultContentConfiguration()
            configuration.text = mantra.title
            configuration.image = mantra.image
            cell.contentConfiguration = configuration
            
            let checkmark = UIImage(systemName: "checkmark.circle.fill",
                                    withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?
                .withTintColor(Constants.accentColor ?? .systemOrange, renderingMode: .alwaysOriginal)
            let circle = UIImage(systemName: "circle",
                                 withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?
                .withTintColor(Constants.accentColor ?? .systemOrange, renderingMode: .alwaysOriginal)
            let badgeConfiguration = UICellAccessory.CustomViewConfiguration(customView: UIImageView(image: mantra.isSelected ? checkmark : circle),
                                                                             placement: .trailing(displayed: .always))
            let badgeAccessory = UICellAccessory.customView(configuration: badgeConfiguration)
            cell.accessories = [badgeAccessory]
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, PreloadedMantra>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: PreloadedMantra) -> UICollectionViewCell? in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, PreloadedMantra>()
        snapshot.appendSections([.main])
        snapshot.appendItems(preloadedMantras)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

//MARK: - UI Methods

extension PreloadedMantraController {
    
    private func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        title = NSLocalizedString("Mantras choice", comment: "Title of PreloadedMantraController")
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
        InitialMantra.sortedData().forEach { (data) in
            let mantra = PreloadedMantra()
            data.forEach { (key, value) in
                if key == .title {
                    mantra.title = value
                }
                if key == .image {
                    if let image = UIImage(named: value) {
                        mantra.image = image.resize(to: CGSize(width: Constants.rowHeight/2, height: Constants.rowHeight/2))
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
        mantraTitles.forEach { (title) in
            if selectedMantrasTitles.contains(title) {
                isDuplicating = true
            }
        }
        return isDuplicating
    }
    
    private func showDuplicatingAlert() {
        let alert = UIAlertController.duplicatingAlertForPreloadedMantras(idiom: traitCollection.userInterfaceIdiom) { [weak self] in
            guard let self = self else { return }
            self.handleAddPreloadedMantra()
        }
        present(alert, animated: true, completion: nil)
    }
    
    private func handleAddPreloadedMantra() {
        dataProvider.addPreloadedMantra(with: selectedMantrasTitles)
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - UICollectionView Delegate

extension PreloadedMantraController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let mantra = dataSource.itemIdentifier(for: indexPath) else { return }
        mantra.isSelected.toggle()
        navigationItem.rightBarButtonItem?.isEnabled = !preloadedMantras.filter{ $0.isSelected }.isEmpty
        
        var newSnapshot = dataSource.snapshot()
        newSnapshot.reloadItems([mantra])
        dataSource.apply(newSnapshot)
    }
}
