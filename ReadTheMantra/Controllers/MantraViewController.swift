//
//  MantraViewController.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 09.12.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit
import CoreData

final class MantraViewController: UICollectionViewController {
    
    enum Section {
        case favorites
        case main
        case other
    }
    
    //MARK: - Properties
    
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Mantra>
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Mantra>
    private lazy var dataSource = makeDataSource()
    
    private lazy var coreDataManager = (UIApplication.shared.delegate as! AppDelegate).coreDataManager
    private lazy var context = (UIApplication.shared.delegate as! AppDelegate).coreDataManager.persistentContainer.viewContext
    
    private lazy var dataProvider: MantraProvider = {
        MantraProvider(fetchedResultsControllerDelegate: self)
    }()
    
    private let widgetManager = WidgetManager()
    
    private var overallMantras: [Mantra] {
        dataProvider.fetchedMantras.filter{ $0.title != "" }
    }
    private lazy var displayedMantras = overallMantras
    private var favoritesSectionMantras: [Mantra] {
        displayedMantras.filter{ $0.isFavorite }
    }
    private var mainSectionMantras: [Mantra] {
        displayedMantras.filter{ !$0.isFavorite }
    }
    
    private let defaults = UserDefaults.standard
    private var isAlphabeticalSorting: Bool {
        get {
            defaults.bool(forKey: "isAlphabeticalSorting")
        }
        set {
            defaults.set(newValue, forKey: "isAlphabeticalSorting")
            dataProvider.loadMantras()
            displayedMantras = overallMantras
            applySnapshot()
            widgetManager.updateWidgetData(for: overallMantras)
        }
    }
    private var isOnboarding: Bool {
        get { defaults.bool(forKey: "isOnboarding") }
        set { defaults.set(newValue, forKey: "isOnboarding") }
    }
    private var isInitalDataLoading: Bool {
        get { defaults.bool(forKey: "isInitalDataLoading") }
        set { defaults.set(newValue, forKey: "isInitalDataLoading") }
    }
    private let activityIndicatorView = UIActivityIndicatorView(style: .large)
        
    private let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var mantraPicker = UIPickerView()
    private lazy var mantraPickerTextField = UITextField(frame: .zero)
    private lazy var sortedInitialMantraData = InitialMantra.sortedData()
    private var coverView: UIView?
    
    private lazy var blurEffectView = BlurEffectView()
    
    //MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupSearchController()
        setupCollectionView()
        dataProvider.loadMantras()
        deleteEmptyMantrasIfNeeded()
        applySnapshot(animatingDifferences: false)
        widgetManager.updateWidgetData(for: overallMantras)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkForOnboardingAlert()
        checkForInitialDataLoading()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] context in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.coverView?.frame = UIScreen.main.bounds
                if self.isOnboarding {
                    self.blurEffectView.updateFrame()
                }
                if self.isInitalDataLoading {
                    self.activityIndicatorView.center = self.view.center
                }
            }
        })
    }
    
    @objc private func handleCoverTap(_ sender: UITapGestureRecognizer? = nil) {
        dismissPreloadedMantraPickerState()
    }
    
    private func checkForOnboardingAlert() {
        if isOnboarding {
            navigationController?.view.addSubview(blurEffectView)
            if let onboardingViewController = storyboard?.instantiateViewController(
                identifier: Constants.onboardingViewController) as? OnboardingViewController {
                onboardingViewController.delegate = self
                if traitCollection.userInterfaceIdiom == .phone {
                    onboardingViewController.modalPresentationStyle = .fullScreen
                } else if traitCollection.userInterfaceIdiom == .pad {
                    onboardingViewController.modalTransitionStyle = .crossDissolve
                }
                present(onboardingViewController, animated: true)
            }
        }
    }
    
    private func checkForInitialDataLoading() {
        if isInitalDataLoading {
            if overallMantras.isEmpty {
                activityIndicatorView.center = view.center
                activityIndicatorView.hidesWhenStopped = true
                view.addSubview(activityIndicatorView)
                activityIndicatorView.startAnimating()
            }
        }
    }
    
    private func deleteEmptyMantrasIfNeeded() {
        favoritesSectionMantras.filter{ $0.title == "" }.forEach { (mantra) in
            context.delete(mantra)
        }
        mainSectionMantras.filter{ $0.title == "" }.forEach { (mantra) in
            context.delete(mantra)
        }
    }
    
    //MARK: - viewDidLoad Setup
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = Constants.accentColor ?? .systemOrange
        
        navigationItem.title = NSLocalizedString("Mantra Counter", comment: "App name")
        navigationItem.searchController = searchController
        navigationItem.leftBarButtonItem = editButtonItem
        
        let newMantraAction = UIAction(title: NSLocalizedString("New Mantra", comment: "Menu Item on MantraViewController"),
                                       image: UIImage(systemName: "square.and.pencil")) { [weak self] action in
            guard let self = self else { return }
            self.showNewMantraVC()
        }
        let preloadedMantraAction = UIAction(title: NSLocalizedString("Preloaded Mantra", comment: "Menu Item on MantraViewController"),
                                             image: UIImage(systemName: "books.vertical")) { [weak self] action in
            guard let self = self else { return }
            self.setPreloadedMantraPickerState()
        }
        let addMenu = UIMenu(children: [newMantraAction, preloadedMantraAction])
        let addBarItem = UIBarButtonItem(systemItem: .add, menu: addMenu)
        
        let sortBarItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), menu: createSortingMenu())
        
        navigationItem.rightBarButtonItems = [addBarItem, sortBarItem]
    }
    
    private func createSortingMenu() -> UIMenu{
        let alphabetSortingAction = UIAction(title: NSLocalizedString("Alphabetically", comment: "Menu Item on MantraViewController"),
                                       image: UIImage(systemName: "textformat")) { [weak self] action in
            guard let self = self else { return }
            self.isAlphabeticalSorting = true
            if let barButtonItem = action.sender as? UIBarButtonItem {
                barButtonItem.menu = self.createSortingMenu()
            }
        }
        let readsCountSortingAction = UIAction(title: NSLocalizedString("Readings count", comment: "Menu Item on MantraViewController"),
                                             image: UIImage(systemName: "text.book.closed")) { [weak self] action in
            guard let self = self else { return }
            self.isAlphabeticalSorting = false
            if let barButtonItem = action.sender as? UIBarButtonItem {
                barButtonItem.menu = self.createSortingMenu()
            }
        }
        
        if isAlphabeticalSorting {
            alphabetSortingAction.state = .on
        } else {
            readsCountSortingAction.state = .on
        }
        
        return UIMenu(children: [alphabetSortingAction, readsCountSortingAction])
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search", comment: "Search Placeholder")
        searchController.definesPresentationContext = true
    }
    
    private func setupCollectionView() {
        createLayout()
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.showsVerticalScrollIndicator = false
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        collectionView.isEditing = editing
    }
}

//MARK: - Home Screen Quick Actions Handling

extension MantraViewController {
    
    func setAddNewMantraMode() {
        showNewMantraVC()
    }
    
    func setSearchMode() {
        searchController.isActive = true
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak searchController] timer in
            guard let searchController = searchController else {
                timer.invalidate()
                return
            }
            if searchController.searchBar.canBecomeFirstResponder {
                searchController.searchBar.becomeFirstResponder()
                timer.invalidate()
            }
        }
    }
}

//MARK: - UICollectionView Data Source

extension MantraViewController {
    
    private func makeDataSource() -> DataSource {
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Mantra> { [weak self] (cell, indexPath, mantra) in
            guard let self = self else { return }
            var configuration = UIListContentConfiguration.subtitleCell()
            configuration.text = mantra.title
            if mantra.title != "" {
                configuration.secondaryText = NSLocalizedString("Current readings:",
                                                                comment: "Current readings count") + " \(mantra.reads)"
                configuration.secondaryTextProperties.color = .secondaryLabel
                configuration.textToSecondaryTextVerticalPadding = 4
                configuration.image = (mantra.imageForTableView != nil) ?
                    UIImage(data: mantra.imageForTableView!) :
                    UIImage(named: Constants.defaultImage)?.resize(to: CGSize(width: Constants.rowHeight,
                                                                              height: Constants.rowHeight))
            }
            cell.contentConfiguration = configuration
            
            var background = UIBackgroundConfiguration.listGroupedCell()
            background.cornerRadius = 15
            cell.backgroundConfiguration = background
            
            // accessories configuration
            let favoriteAction = UIAction(image: UIImage(systemName: mantra.isFavorite ? "star.slash" : "star"),
                                          handler: { _ in
                                            mantra.isFavorite.toggle()})
            let favoriteButton = UIButton(primaryAction: favoriteAction)
            let favoriteAccessoryConfiguration = UICellAccessory.CustomViewConfiguration(customView: favoriteButton,
                                                                                         placement: .leading(displayed: .whenEditing))
            let favoriteAccessory = UICellAccessory.customView(configuration: favoriteAccessoryConfiguration)
            let deleteAccessory = UICellAccessory.delete(displayed: .whenEditing,
                                                         actionHandler: { [weak self] in
                                                            guard let self = self else { return }
                                                            self.showDeleteConfirmationAlert(for: mantra) })
            let disclosureIndicatorAccessory = UICellAccessory.disclosureIndicator()
            let badge = UIImage(systemName: "checkmark.circle.fill",
                                withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?
                .withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
            let badgeConfiguration = UICellAccessory.CustomViewConfiguration(customView: UIImageView(image: badge),
                                                                             placement: .trailing(displayed: .always),
                                                                             isHidden: mantra.readsGoal > mantra.reads)
            let badgeAccessory = UICellAccessory.customView(configuration: badgeConfiguration)

            cell.accessories = [deleteAccessory, favoriteAccessory, disclosureIndicatorAccessory, badgeAccessory]
        }
        
        let dataSource = DataSource(collectionView: collectionView) { (collectionView, indexPath, mantra) -> UICollectionViewCell? in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: mantra)
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(elementKind: "Header") {
            (supplementaryView, string, indexPath) in
            
            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            switch section {
            case .favorites:
                supplementaryView.label.text = NSLocalizedString("Favorites", comment: "Favorites section title")
            case .main:
                supplementaryView.label.text = NSLocalizedString("Mantras", comment: "Main section title")
            case .other:
                supplementaryView.label.text = NSLocalizedString("Other Mantras", comment: "Other section title")
            }
        }
        
        dataSource.supplementaryViewProvider = { (view, kind, index) in
            self.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: index)
        }
        
        return dataSource
    }
    
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        if !favoritesSectionMantras.isEmpty {
            snapshot.appendSections([Section.favorites])
            snapshot.appendItems(favoritesSectionMantras, toSection: .favorites)
        }
        if !mainSectionMantras.isEmpty && favoritesSectionMantras.isEmpty {
            snapshot.appendSections([Section.main])
            snapshot.appendItems(mainSectionMantras, toSection: .main)
        }
        
        if !mainSectionMantras.isEmpty && !favoritesSectionMantras.isEmpty {
            snapshot.appendSections([Section.other])
            snapshot.appendItems(mainSectionMantras, toSection: .other)
        }
        
        snapshot.reloadItems(snapshot.itemIdentifiers)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

//MARK: - UICollectionView Layout

extension MantraViewController {
    
    private func createLayout() {
        
        let layout = UICollectionViewCompositionalLayout { (_, layoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let spacing: CGFloat = 5
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(CGFloat(Constants.rowHeight)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                           subitem: item,
                                                           count: layoutEnvironment.traitCollection.userInterfaceIdiom == .pad ? 2 : 1)
            group.interItemSpacing = .fixed(spacing)
            let sideSpacing: CGFloat = 10
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                            leading: sideSpacing,
                                                            bottom: 10,
                                                            trailing: sideSpacing)
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .absolute(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                     elementKind: "Header",
                                                                     alignment: .top)
            section.boundarySupplementaryItems = [header]
            section.interGroupSpacing = spacing
            return section
        }
        collectionView.collectionViewLayout = layout
    }
}

//MARK: - UICollectionView Delegate

extension MantraViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let mantra = dataSource.itemIdentifier(for: indexPath) else { return }
        
        guard let readsCountViewController = storyboard?.instantiateViewController(
                identifier: Constants.readsCountViewControllerID,
                creator: { coder in
                    return ReadsCountViewController(mantra: mantra, coder: coder)
                }) else { return }
        navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Mantra List", comment: "Back button of MantraViewController"),
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
        show(readsCountViewController, sender: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let mantra = dataSource.itemIdentifier(for: indexPath) else { return nil }
        let title = mantra.isFavorite ?
            NSLocalizedString("Unfavorite", comment: "Menu Action on MantraViewController") :
            NSLocalizedString("Favorite", comment: "Menu Action on MantraViewController")
        let image = mantra.isFavorite ? UIImage(systemName: "star.slash") : UIImage(systemName: "star")
        
        let favorite = UIAction(title: title, image: image) { _ in
            mantra.isFavorite.toggle()
        }
        
        let delete = UIAction(title: NSLocalizedString("Delete", comment: "Menu Action on MantraViewController"),
                              image: UIImage(systemName: "trash"),
                              attributes: [.destructive]) { [weak self] _ in
            guard let self = self else { return }
            self.showDeleteConfirmationAlert(for: mantra)
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(children: [favorite, delete])
        }
    }
}

//MARK: - Delete Mantra Stack

extension MantraViewController {
    
    private func showDeleteConfirmationAlert(for mantra: Mantra) {
        let alert = UIAlertController.deleteConfirmationAlert(for: mantra) { [weak self] (mantra) in
            guard let self = self else { return }
            self.dataProvider.deleteMantra(mantra)
        }
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - Add New Mantra Stack

extension MantraViewController {
    
    private func showNewMantraVC() {
        let mantra = Mantra(context: context)
        mantra.uuid = UUID()
        guard let detailsViewController = storyboard?.instantiateViewController(
                identifier: Constants.detailsViewControllerID,
                creator: { [weak self] coder in
                    guard let self = self else { fatalError() }
                    return DetailsViewController(mantra: mantra,
                                                 mode: .add,
                                                 mantraTitles: self.overallMantras.compactMap({ $0.title }),
                                                 delegate: self,
                                                 coder: coder)
                }) else { return }
        let navigationController = UINavigationController(rootViewController: detailsViewController)
        present(navigationController, animated: true)
    }
    
    private func setPreloadedMantraPickerState() {
        setDimmedBackground()
        makeAndShowMantraPickerView()
        navigationController?.navigationBar.tintColor = traitCollection.userInterfaceStyle == .light ? .systemGray : .systemGray2
    }
    
    private func setDimmedBackground() {
        let dimmedBackgroundView = UIView(frame: UIScreen.main.bounds)
        dimmedBackgroundView.backgroundColor = .black
        dimmedBackgroundView.alpha = 0
        let dimmedAlpha = traitCollection.userInterfaceStyle == .light ? 0.2 : 0.5
        coverView = dimmedBackgroundView
        if let coverView = coverView {
            coverView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCoverTap(_:))))
            navigationController?.view.addSubview(coverView)
            UIView.animate(withDuration: 0.15) {
                coverView.alpha = CGFloat(dimmedAlpha)
            }
        }
    }
    
    private func makeAndShowMantraPickerView() {
        
        mantraPicker.dataSource = self
        mantraPicker.delegate = self
        
        // custom toolbar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.tintColor = Constants.accentColor ?? .systemOrange
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(systemItem: .done, primaryAction: UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            self.donePreloadedMantraButtonPressed()
        }))
        let cancelButton = UIBarButtonItem(systemItem: .cancel, primaryAction: UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            self.cancelPreloadedMantraButtonPressed()
        }))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        navigationController?.view.addSubview(mantraPickerTextField)
        
        mantraPickerTextField.inputView = mantraPicker
        mantraPickerTextField.inputAccessoryView = toolBar
        mantraPicker.selectRow(0, inComponent: 0, animated: false)
        mantraPickerTextField.becomeFirstResponder()
    }
    
    private func cancelPreloadedMantraButtonPressed() {
        dismissPreloadedMantraPickerState()
    }
    
    private func donePreloadedMantraButtonPressed() {
        mantraPickerTextField.resignFirstResponder()
        if isMantraDuplicating() {
            dismissPreloadedMantraPickerState()
            showDuplicatingAlert()
        } else {
            handleAddPreloadedMantra()
        }
    }
    
    private func isMantraDuplicating() -> Bool {
        let selectedMantraNumber = mantraPicker.selectedRow(inComponent: 0)
        guard let title = sortedInitialMantraData[selectedMantraNumber][.title] else { return false }
        return overallMantras.compactMap({ $0.title }).contains(title)
    }
    
    private func showDuplicatingAlert() {
        let alert = UIAlertController.duplicatingAlert { [weak self] in
            guard let self = self else { return }
            self.handleAddPreloadedMantra()
        } cancelActionHandler: { [weak self] in
            guard let self = self else { return }
            self.dismissPreloadedMantraPickerState()
        }
        present(alert, animated: true, completion: nil)
    }
    
    private func handleAddPreloadedMantra() {
        dataProvider.addPreloadedMantra(with: mantraPicker.selectedRow(inComponent: 0))
        dismissPreloadedMantraPickerState()
    }
    
    private func dismissPreloadedMantraPickerState() {
        coverView?.removeFromSuperview()
        coverView = nil
        mantraPickerTextField.resignFirstResponder()
        navigationController?.navigationBar.tintColor = Constants.accentColor ?? .systemOrange
    }
}

// MARK: - NSFetchedResultsController Delegate

extension MantraViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if !searchController.isActive {
            displayedMantras = overallMantras
        }
        applySnapshot()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.coreDataManager.saveContext()
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            self.widgetManager.updateWidgetData(for: self.overallMantras)
        }
        
        stopActivityIndicatorForInitialDataLoadingIfNeeded()
    }
    
    private func stopActivityIndicatorForInitialDataLoadingIfNeeded() {
        if isInitalDataLoading {
            if !overallMantras.isEmpty {
                activityIndicatorView.stopAnimating()
                activityIndicatorView.removeFromSuperview()
                isInitalDataLoading.toggle()
            }
        }
    }
}

// MARK: - UISearchResultsUpdating Delegate

extension MantraViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        performSearch()
    }
    
    private func performSearch() {
        guard let text = searchController.searchBar.text else { return }
        if text.isEmpty {
            displayedMantras = overallMantras
            applySnapshot()
            return
        }
        displayedMantras = overallMantras.filter{
            if let title = $0.title {
                return title.localizedCaseInsensitiveContains(text)
            } else {
                return false
            }
        }
        applySnapshot()
    }
}

//MARK: - PickerView DataSource

extension MantraViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        sortedInitialMantraData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        sortedInitialMantraData[row][.title]
    }
}

//MARK: - DetailsViewController Delegate

extension MantraViewController: DetailsViewControllerDelegate {
    
    func updateView() {
        // UI updates automactically
    }
}

//MARK: - OnboardingViewController Delegate

extension MantraViewController: OnboardingViewControllerDelegate {
    
    func dismissButtonPressed() {
        blurEffectView.animateOut()
        isOnboarding.toggle()
    }
}
