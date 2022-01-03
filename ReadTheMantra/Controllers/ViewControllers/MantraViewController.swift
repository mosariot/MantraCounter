//
//  MantraViewController.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 09.12.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit
import CoreData

protocol MantraViewControllerDelegate: AnyObject {
    func mantraSelected(_ newMantra: Mantra?)
}

final class MantraViewController: UICollectionViewController {
    
    enum Section {
        case favorites
        case main
        case other
    }
    
    //MARK: - Properties
    
    weak var delegate: MantraViewControllerDelegate?
    
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Mantra.ID>
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Mantra.ID>
    private lazy var dataSource = makeDataSource()
    
    private(set) lazy var mantraDataManager: DataManager = MantraDataManager()
    private let mantraWidgetManager: WidgetManager = MantraWidgetManager()
    private lazy var dataStore = DataStore(dataManager: mantraDataManager)
    private var selectedMantra: Mantra? {
        didSet { delegate?.mantraSelected(selectedMantra) }
    }
    
    private lazy var noResultsForSearchLabel = PlaceholderLabelForEmptyView.makeLabel(
        inView: view,
        withText: NSLocalizedString("No matches found", comment: "No matches found"),
        textStyle: .title3)
    
    private var isColdStart = true
    private var isPadOrMacIdiom: Bool {
        traitCollection.userInterfaceIdiom == .pad || traitCollection.userInterfaceIdiom == .mac
    }
    private var isPhoneIdiom: Bool {
        traitCollection.userInterfaceIdiom == .phone
    }
    private var isAppReadyForDeeplinkOrShortcut = false
    
    private let defaults = UserDefaults.standard

    private var isPreloadedMantrasDueToNoInternetConnection: Bool {
        get { defaults.bool(forKey: "isPreloadedMantrasDueToNoInternetConnection") }
        set { defaults.set(newValue, forKey: "isPreloadedMantrasDueToNoInternetConnection") }
    }
    private var isOnboarding: Bool {
        get { defaults.bool(forKey: "isOnboarding") }
        set { defaults.set(newValue, forKey: "isOnboarding") }
    }
    private var isInitalDataLoading: Bool {
        get { defaults.bool(forKey: "isInitalDataLoading") }
        set { defaults.set(newValue, forKey: "isInitalDataLoading") }
    }
    private lazy var activityIndicator = ActivityIndicatorViewWithText.makeView(
        inView: navigationController?.view ?? view,
        withText: NSLocalizedString("LOADING", comment: "Loading from iCloud"))
    
    private lazy var blurEffectView = BlurEffectView.makeView(
        inView: splitViewController?.view ?? view)
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSearchController()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Mantra List", comment: "Back button of MantraViewController"),
            style: .plain,
            target: nil,
            action: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isColdStart {
            Task { await checkForOnboarding() }
            mantraDataManager.loadMantras()
            Task { await listenForSortingChange() }
            Task { await listenForDataChange() }
            loadFirstMantraForSecondaryView()
            applySnapshot()
            mantraWidgetManager.updateWidgetData(with: dataStore.overallMantras)
            checkForInitialDataLoading()
            reselectSelectedMantraIfNeeded()
            isAppReadyForDeeplinkOrShortcut = true
            isColdStart = false
        }
    }
    
    private func listenForSortingChange() async {
        for await _ in await dataStore.listenForSortingChange() {
            mantraWidgetManager.updateWidgetData(with: dataStore.overallMantras)
            await MainActor.run { applySnapshot() }
        }
    }
    
    @MainActor
    private func listenForDataChange() async {
        for await isValueChangedByUser in await mantraDataManager.listenForDataChange() {
            handleSearchControllerResultsIfNeeded()
            applySnapshot(withReconfiguration: true)
            reselectSelectedMantraIfNeeded()
            if !isValueChangedByUser {
                updateSecondaryView()
            }
            stopActivityIndicatorForInitialDataLoadingIfNeeded()
            mantraWidgetManager.updateWidgetData(with: dataStore.overallMantras)
            afterDelay(Constants.progressAnimationDuration) { self.mantraDataManager.saveMantras() }
//            mantraDataManager.saveMantras()
        }
    }
    
    private func handleSearchControllerResultsIfNeeded() {
        if searchController.isActive {
            searchController.searchBar.text! += " "
            searchController.searchBar.text! = String(searchController.searchBar.text!.dropLast())
        } else {
            dataStore.syncDisplayedMantrasWithOverallMantras()
        }
    }
    
    private func updateSecondaryView() {
            guard let selectedMantra = self.selectedMantra else { return }
            if !self.dataStore.overallMantras.contains(selectedMantra) {
                self.selectedMantra = nil
            }
            self.delegate?.mantraSelected(self.selectedMantra)
    }
    
    private func stopActivityIndicatorForInitialDataLoadingIfNeeded() {
        if isInitalDataLoading {
            if !dataStore.overallMantras.isEmpty {
                activityIndicator.removeFromSuperview()
                loadFirstMantraForSecondaryView()
                reselectSelectedMantraIfNeeded()
                mantraWidgetManager.updateWidgetData(with: dataStore.overallMantras)
                isInitalDataLoading = false
            }
        }
    }
    
    
    private func loadFirstMantraForSecondaryView() {
        if let firstFavoriteMantra = dataStore.favoritesSectionMantras.first {
            selectedMantra = firstFavoriteMantra
        } else if let firstMantra = dataStore.mainSectionMantras.first {
            selectedMantra = firstMantra
        } else {
            selectedMantra = nil
        }
    }
    
    private func reselectSelectedMantraIfNeeded() {
        if isPadOrMacIdiom {
            if let selectedMantra = selectedMantra {
                collectionView.indexPathsForSelectedItems?
                    .forEach { collectionView.deselectItem(at: $0, animated: false) }
                let indexPath = dataSource.indexPath(for: selectedMantra.id)
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
            }
        }
    }
    
    @MainActor
    private func checkForOnboarding() async {
        if isOnboarding {
            blurEffectView.animateIn()
            let onboardingHandler = OnboardingHandler(caller: self)
            if await onboardingHandler.isOnboardingCompleted() {
                blurEffectView.animateOut()
                isOnboarding = false
                if isPreloadedMantrasDueToNoInternetConnection {
                    AlertCenter.showPreloadedMantrasDueToNoInternetConnectionAlert(in: self)
                    mantraWidgetManager.updateWidgetData(with: dataStore.overallMantras)
                    isPreloadedMantrasDueToNoInternetConnection = false
                }
            }
        }
    }
    
    private func checkForInitialDataLoading() {
        if isInitalDataLoading {
            if dataStore.overallMantras.isEmpty {
                activityIndicator.isHidden = false
            }
        }
    }
    
    //MARK: - viewDidLoad Setup
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.title = NSLocalizedString("Mantra Reader", comment: "App name")
        navigationItem.searchController = searchController
        navigationItem.leftBarButtonItem = editButtonItem
        
        let newMantraAction = UIAction(
            title: NSLocalizedString("New Mantra", comment: "Menu Item on MantraViewController"),
            image: UIImage(systemName: "square.and.pencil")) { [weak self] action in
            guard let self = self else { return }
            self.showNewMantraVC()
        }
        let preloadedMantraAction = UIAction(
            title: NSLocalizedString("Preset Mantra", comment: "Menu Item on MantraViewController"),
            image: UIImage(systemName: "books.vertical")) { [weak self] action in
            guard let self = self else { return }
            self.showPreloadedMantraVC()
        }
        let addMenu = UIMenu(children: [newMantraAction, preloadedMantraAction])
        let addBarItem = UIBarButtonItem(systemItem: .add, menu: addMenu)
        
        let sortBarItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), menu: createSortingMenu())
        
        navigationItem.rightBarButtonItems = [addBarItem, sortBarItem]
    }
    
    private func createSortingMenu() -> UIMenu{
        let alphabetSortingAction = UIAction(
            title: NSLocalizedString("Alphabetically", comment: "Menu Item on MantraViewController"),
            image: UIImage(systemName: "textformat")) { [weak self] action in
                guard let self = self else { return }
                self.dataStore.isAlphabeticalSorting = true
                if let barButtonItem = action.sender as? UIBarButtonItem {
                    barButtonItem.menu = self.createSortingMenu()
                }
            }
        let readsCountSortingAction = UIAction(
            title: NSLocalizedString("By readings count", comment: "Menu Item on MantraViewController"),
            image: UIImage(systemName: "text.book.closed")) { [weak self] action in
                guard let self = self else { return }
                self.dataStore.isAlphabeticalSorting = false
                if let barButtonItem = action.sender as? UIBarButtonItem {
                    barButtonItem.menu = self.createSortingMenu()
                }
            }
        
        if dataStore.isAlphabeticalSorting {
            alphabetSortingAction.state = .on
        } else {
            readsCountSortingAction.state = .on
        }
        
        return UIMenu(children: [alphabetSortingAction, readsCountSortingAction])
    }
    
    private func setupSearchController() {
        let searchControllerHandler = SearchControllerHandler(searchController)
        Task { await listenForSearchUpdating(searchControllerHandler) }
        Task { await listenForSearchControllerDismiss(searchControllerHandler) }
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search", comment: "Search Placeholder")
        searchController.definesPresentationContext = true
    }
    
    @MainActor
    private func listenForSearchUpdating(_ searchControllerHandler: SearchControllerHandler) async {
        for await _ in await searchControllerHandler.listenForSearchUpdating() {
            performSearch()
            if dataStore.displayedMantras.isEmpty {
                noResultsForSearchLabel.isHidden = false
            } else {
                noResultsForSearchLabel.isHidden = true
            }
        }
    }
    
    private func performSearch() {
        guard let text = searchController.searchBar.text else { return }
        if text.isEmpty {
            dataStore.syncDisplayedMantrasWithOverallMantras()
            noResultsForSearchLabel.isHidden = true
            applySnapshot()
            return
        }
        dataStore.filterDisplayedMantrasWith(text)
        applySnapshot()
    }
    
    private func listenForSearchControllerDismiss(_ searchControllerHandler: SearchControllerHandler) async {
        for await _ in await searchControllerHandler.listenForSearchControllerDismiss() {
            await MainActor.run { noResultsForSearchLabel.isHidden = true }
        }
    }
    
    private func setupCollectionView() {
        createLayout()
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.showsVerticalScrollIndicator = false
        if isPadOrMacIdiom {
            clearsSelectionOnViewWillAppear = false
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        collectionView.isEditing = editing
        reselectSelectedMantraIfNeeded()
    }
}

//MARK: - Home Screen Shortcuts Handling

extension MantraViewController {
    
    func setAddNewMantraMode() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            if self.isAppReadyForDeeplinkOrShortcut {
                self.showNewMantraVC()
                timer.invalidate()
            }
        }
    }
    
    func setSearchMode() {
        searchController.isActive = true
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak searchController, weak self] timer in
            guard let searchController = searchController, let self = self else {
                timer.invalidate()
                return
            }
            if self.isAppReadyForDeeplinkOrShortcut && searchController.searchBar.canBecomeFirstResponder {
                searchController.searchBar.becomeFirstResponder()
                timer.invalidate()
            }
        }
    }
}

//MARK: - UICollectionView Data Source

extension MantraViewController {
    
    private func makeDataSource() -> DataSource {
        
        let cellRegistration = UICollectionView.CellRegistration<MantraCell, Mantra> { [weak self] cell, indexPath, mantra in
            guard let self = self else { return }
            cell.mantra = mantra
            cell.delegate = self
        }
        
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, mantraID -> UICollectionViewCell? in
            let mantra = self.dataStore.mantraFor(mantraID)
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: mantra)
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<HeaderSupplementaryView>(elementKind: "Header") {
            supplementaryView, string, indexPath in
            supplementaryView.section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
        }
        
        dataSource.supplementaryViewProvider = { view, kind, index in
            self.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: index)
        }
        
        return dataSource
    }
    
    private func applySnapshot(withReconfiguration: Bool = false) {
        var snapshot = Snapshot()
        let favoritesSectionMantrasIDs = dataStore.favoritesSectionMantrasIDs()
        let mainSectionMantrasIDs = dataStore.mainSectionMantrasIDs()
        if !dataStore.favoritesSectionMantras.isEmpty {
            snapshot.appendSections([.favorites])
            snapshot.appendItems(favoritesSectionMantrasIDs, toSection: .favorites)
        }
        if !dataStore.mainSectionMantras.isEmpty && dataStore.favoritesSectionMantras.isEmpty {
            snapshot.appendSections([.main])
            snapshot.appendItems(mainSectionMantrasIDs, toSection: .main)
        }
        if !dataStore.mainSectionMantras.isEmpty && !dataStore.favoritesSectionMantras.isEmpty {
            snapshot.appendSections([.other])
            snapshot.appendItems(mainSectionMantrasIDs, toSection: .other)
        }
        if withReconfiguration {
            if #available(iOS 15, *) {
                snapshot.reconfigureItems(snapshot.itemIdentifiers)
            }
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

//MARK: - UICollectionView Layout

extension MantraViewController {
    
    private func createLayout() {
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            configuration.headerMode = .supplementary
            
            // Swipe Actions
            configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
                guard let self = self,
                      let mantraID = self.dataSource.itemIdentifier(for: indexPath),
                      let mantra = self.dataStore.mantraFor(mantraID)
                else { return nil }
                
                let title = mantra.isFavorite ?
                    NSLocalizedString("Unfavorite", comment: "Menu Action on MantraViewController") :
                    NSLocalizedString("Favorite", comment: "Menu Action on MantraViewController")
                let image = mantra.isFavorite ? UIImage(systemName: "star.slash") : UIImage(systemName: "star")
                
                let favorite = UIContextualAction(style: .normal, title: title) { _, _, completion in
                    mantra.isFavorite.toggle()
                    completion(true)
                }
                favorite.image = image
                favorite.backgroundColor = .systemBlue
                
                let delete = UIContextualAction(
                    style: .destructive,
                    title: NSLocalizedString("Delete", comment: "Menu Action on MantraViewController")) { _, _, completion in
                        Task { await self.showDeleteConfirmationAlert(for: mantra) }
                        completion(true)
                    }
                delete.image = UIImage(systemName: "trash")
                return UISwipeActionsConfiguration(actions: [delete, favorite])
            }
            
            // Header
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(50))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: "Header",
                alignment: .top)
            
            // Section
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            section.boundarySupplementaryItems = [header]
            
            return section
        }
        
        collectionView.collectionViewLayout = layout
    }
}

//MARK: - DeepLink from Widget

extension MantraViewController {
    
    func goToMantraWith(_ id: UUID) {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            if self.isAppReadyForDeeplinkOrShortcut {
                guard let mantra = self.dataStore.mantraFor(id) else { return }
                self.selectedMantra = mantra
                self.reselectSelectedMantraIfNeeded()
                self.defaults.set(false, forKey: "collapseSecondaryViewController")
                if let readsCountViewController = self.delegate as? ReadsCountViewController,
                   let readsCountNavigationController = readsCountViewController.navigationController {
                    self.splitViewController?.showDetailViewController(readsCountNavigationController, sender: nil)
                }
                timer.invalidate()
            }
        }
    }
}

//MARK: - UICollectionView Delegate (Selection of Cells)

extension MantraViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let mantraID = dataSource.itemIdentifier(for: indexPath),
              let mantra = dataStore.mantraFor(mantraID)
        else { return }
        selectedMantra = mantra
        defaults.set(false, forKey: "collapseSecondaryViewController")
        if let readsCountViewController = delegate as? ReadsCountViewController,
           let readsCountNavigationController = readsCountViewController.navigationController {
            splitViewController?.showDetailViewController(readsCountNavigationController, sender: nil)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let mantraID = dataSource.itemIdentifier(for: indexPath),
              let mantra = dataStore.mantraFor(mantraID)
        else { return nil }
        let title = mantra.isFavorite ?
            NSLocalizedString("Unfavorite", comment: "Menu Action on MantraViewController") :
            NSLocalizedString("Favorite", comment: "Menu Action on MantraViewController")
        let image = mantra.isFavorite ? UIImage(systemName: "star.slash") : UIImage(systemName: "star")
        
        let favorite = UIAction(title: title, image: image) { _ in
            // wait for animation completes
            afterDelay(0.7) {
                mantra.isFavorite.toggle()
            }
        }
        
        let delete = UIAction(title: NSLocalizedString("Delete", comment: "Menu Action on MantraViewController"),
                              image: UIImage(systemName: "trash"),
                              attributes: [.destructive]) { [weak self] _ in
            guard let self = self else { return }
            Task { await self.showDeleteConfirmationAlert(for: mantra) }
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(children: [favorite, delete])
        }
    }
}

//MARK: - Add New Mantra Stack

extension MantraViewController {
    
    private func showPreloadedMantraVC() {
        let preloadedMantraController = PreloadedMantraController(mantraDataManager: mantraDataManager)
        let navigationController = UINavigationController(rootViewController: preloadedMantraController)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true)
    }
    
    private func showNewMantraVC() {
        let mantra = mantraDataManager.makeNewMantra()
        mantra.uuid = UUID()
        guard let detailsViewController = storyboard?.instantiateViewController(
                identifier: Constants.detailsViewControllerID,
                creator: { [weak self] coder in
                    guard let self = self else { fatalError() }
                    return DetailsViewController(
                        mantra: mantra,
                        state: .addDetailsState(),
                        mantraDataManager: self.mantraDataManager,
                        callerController: self,
                        coder: coder)
                }) else { return }
        let navigationController = UINavigationController(rootViewController: detailsViewController)
        navigationController.isModalInPresentation = true
        present(navigationController, animated: true)
    }
}

//MARK: - MantraCellDelegate

extension MantraViewController: MantraCellDelegate {
    
    @MainActor
    func showDeleteConfirmationAlert(for mantra: Mantra) async {
        if await AlertCenter.confirmDeletion(in: self, for: mantra, idiom: traitCollection.userInterfaceIdiom) {
            if selectedMantra == mantra {
                selectedMantra = nil
            }
            mantraDataManager.deleteMantra(mantra)
        }
    }
}
