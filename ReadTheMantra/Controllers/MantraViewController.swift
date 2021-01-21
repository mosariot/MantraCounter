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
    
    //MARK: - Properties
    
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Mantra>
    private typealias DataSource = CollectionViewDataSourceManager.DataSource
    private var dataSourceManager = CollectionViewDataSourceManager()
    private lazy var dataSource = makeDataSource()
    
    private let coreDataManager = CoreDataManager.shared
    private lazy var context = coreDataManager.persistentContainer.viewContext
    
    private let widgetManager = WidgetManager()
    
    private var fetchedResultsController: NSFetchedResultsController<Mantra>?
    
    private let defaults = UserDefaults.standard
    private var isInFavoriteMode: Bool {
        get {
            defaults.bool(forKey: "isInFavoriteMode")
        }
        set {
            defaults.set(newValue, forKey: "isInFavoriteMode")
            dataSourceManager.isInFavoriteMode = isInFavoriteMode
            loadMantras()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
                self.reloadDataSource()
            }
        }
    }
    private var wasShownOnboardingAlert: Bool {
        get { defaults.bool(forKey: "wasShownOnboardingAlert") }
        set { defaults.set(newValue, forKey: "wasShownOnboardingAlert") }
    }
    
    private var overallMantraCount = 0
    private var currentMantraCount = 0
    private var overallMantraTitles: [String] = []
    private var overallFavoriteMantraCount: Int {
        dataSource.snapshot().itemIdentifiers.filter({ $0.isFavorite }).count
    }
    
    private let segmentedControl = UISegmentedControl(items: [NSLocalizedString("All", comment: "Segment Title on MantraViewController"),
                                                              UIImage(systemName: "star") ?? ""])
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var mantraPicker = UIPickerView()
    private lazy var mantraPickerTextField = UITextField(frame: .zero)
    private var coverView: UIView?
    private lazy var sortedInitialMantraData = InitialMantra.sortedData()
    
    private lazy var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        return blurEffectView
    }()
    
    //MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupSearchController()
        setupCollectionView()
        loadMantras(animatingDifferences: false)
        widgetManager.updateWidgetData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        setupSegmentedControl()
        reloadDataSource()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        checkForOnboardingAlert()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] context in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.setupSegmentedControl()
                self.coverView?.frame = UIScreen.main.bounds
                if !self.wasShownOnboardingAlert {
                    self.blurEffectView.frame = UIScreen.main.bounds
                }
            }
        })
    }
    
    @objc private func handleCoverTap(_ sender: UITapGestureRecognizer? = nil) {
        dismissPreloadedMantraPickerState()
    }
    
    private func checkForOnboardingAlert() {
        if !wasShownOnboardingAlert {
            setupBlurEffectView()
            animateBlurEffectViewIn()
            if let onboardingViewController = storyboard?.instantiateViewController(identifier: Constants.onboardingViewController) as? OnboardingViewController {
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
    
    //MARK: - viewDidLoad Setup
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.titleView = segmentedControl
        
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
        let addingMenu = UIMenu(children: [newMantraAction, preloadedMantraAction])
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .add, primaryAction: nil, menu: addingMenu)
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
    
    private func setupSegmentedControl() {
        segmentedControl.selectedSegmentIndex = isInFavoriteMode ? 1 : 0
        segmentedControl.addTarget(self, action: #selector(segmentedValueChanged), for: .valueChanged)
        segmentedControl.setWidth(view.frame.size.width/6, forSegmentAt: 0)
        segmentedControl.setWidth(view.frame.size.width/6, forSegmentAt: 1)
        segmentedControl.sizeToFit()
    }
    
    @objc private func segmentedValueChanged() {
        isInFavoriteMode.toggle()
    }
    
    private func getCurrentMantrasInfo() {
        var overallMantraArray: [Mantra] = []
        let request: NSFetchRequest<Mantra> = Mantra.fetchRequest()
        do {
            overallMantraArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        overallMantraCount = overallMantraArray.count
        overallMantraTitles = overallMantraArray.compactMap({ $0.title })
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        collectionView.isEditing = editing
    }
}

//MARK: - Home Screen Quick Actions Handling

extension MantraViewController {
    
    func setFavoriteMode() {
        isInFavoriteMode = true
    }
    
    func setAddNewMantraMode() {
        showNewMantraVC()
    }
    
    func setSearchMode() {
        isInFavoriteMode = false
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
       dataSourceManager.isInFavoriteMode = isInFavoriteMode
        
       return dataSourceManager.makeDataSource(collectionView: collectionView) { [weak self] (mantra) in
            guard let self = self else { return }
            self.handleFavoriteAction(for: mantra)
            if !self.isInFavoriteMode {
                self.reloadDataSource()
            }
        } deleteActionHandler: { [weak self] (mantra) in
            guard let self = self else { return }
            self.showDeleteConfirmationAlert(for: mantra)
        } canReorderingHandler: { [weak self] in
            guard let self = self else { return false }
            return !self.searchController.isActive
        } reorderingHandler: { [weak self] (snapshot) in
            guard let self = self else { return }
            if self.isInFavoriteMode {
                self.reorderFavoriteMantraPositionsForReordering(withSnapshot: snapshot)
            } else {
                self.reorderMantraPositions(withSnapshot: snapshot)
            }
            DispatchQueue.main.async {
                self.coreDataManager.saveContext()
                self.widgetManager.updateWidgetData()
            }
        }
    }
    
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(fetchedResultsController?.fetchedObjects ?? [], toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    private func reloadDataSource(animatingDifferences: Bool = true) {
        var snapshot = dataSource.snapshot()
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
            
            let spacing: CGFloat = 10
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(CGFloat(Constants.rowHeight)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                           subitem: item,
                                                           count: layoutEnvironment.container.effectiveContentSize.width >= 1024 ? 2 : 1)
            group.interItemSpacing = .fixed(spacing)
            
            let sideSpacing: CGFloat = layoutEnvironment.container.effectiveContentSize.width > 375 ? 10 : 5
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                            leading: sideSpacing,
                                                            bottom: 0,
                                                            trailing: sideSpacing)
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
                creator: { [weak self] coder in
                    guard let self = self else { fatalError() }
                    return ReadsCountViewController(mantra: mantra,
                                                    positionFavorite: Int32(self.overallFavoriteMantraCount),
                                                    delegate: self,
                                                    coder: coder)
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
        
        let favorite = UIAction(title: title, image: image) { [weak self] _ in
            guard let self = self else { return }
            self.handleFavoriteAction(for: mantra)
        }
        
        let delete = UIAction(title: NSLocalizedString("Delete", comment: "Menu Action on MantraViewController"),
                              image: UIImage(systemName: "trash"),
                              attributes: [.destructive]) { [weak self] _ in
            guard let self = self else { return }
            self.showDeleteConfirmationAlert(for: mantra)
        }
        
        let children = isInFavoriteMode ? [favorite] : [favorite, delete]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(children: children)
        }
    }
}

//MARK: - Cells Manipulation Methods

extension MantraViewController {
    
    private func showDeleteConfirmationAlert(for mantra: Mantra) {
        let alert = UIAlertController.deleteConfirmationAlert(for: mantra) { [weak self] (mantra) in
            guard let self = self else { return }
            self.handleDeleteMantra(mantra)
        }
        present(alert, animated: true, completion: nil)
    }
    
    private func handleDeleteMantra(_ mantra: Mantra) {
        context.delete(mantra)
        
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([mantra])
        applySnapshot()
        
        reorderMantraPositions(withSnapshot: snapshot)
        reorderFavoriteMantraPositionsForDeleting(withSnapshot: snapshot)
        
        coreDataManager.saveContext()
        
        overallMantraCount = snapshot.itemIdentifiers.count
        overallMantraTitles = snapshot.itemIdentifiers.compactMap({ $0.title })
        widgetManager.updateWidgetData()
    }
    
    private func handleFavoriteAction(for mantra: Mantra) {
        mantra.isFavorite.toggle()
        if mantra.isFavorite {
            mantra.positionFavorite = Int32(overallFavoriteMantraCount)
        } else {
            mantra.positionFavorite = 0
        }
        
        reorderFavoriteMantraPositionsForDeleting(withSnapshot: dataSource.snapshot())
        
        coreDataManager.saveContext()
        if isInFavoriteMode {
            applySnapshot()
        }
        widgetManager.updateWidgetData()
    }
    
    private func reorderMantraPositions(withSnapshot snapshot: Snapshot) {
        for (n, mantra) in snapshot.itemIdentifiers.enumerated() {
            mantra.position = Int32(n)
        }
    }
    
    private func reorderFavoriteMantraPositionsForDeleting(withSnapshot snapshot: Snapshot) {
        for (n, mantra) in snapshot.itemIdentifiers.filter({ $0.isFavorite }).sorted(by: { $0.positionFavorite < $1.positionFavorite }).enumerated() {
            mantra.positionFavorite = Int32(n)
        }
    }
    
    private func reorderFavoriteMantraPositionsForReordering(withSnapshot snapshot: Snapshot) {
        for (n, mantra) in snapshot.itemIdentifiers.enumerated() {
            mantra.positionFavorite = Int32(n)
        }
    }
}

//MARK: - Add New Mantra Stack

extension MantraViewController {
    
    private func showNewMantraVC() {
        getCurrentMantrasInfo()
        currentMantraCount = overallMantraCount
        let mantra = Mantra(context: context)
        guard let detailsViewController = storyboard?.instantiateViewController(
                identifier: Constants.detailsViewControllerID,
                creator: { [weak self] coder in
                    guard let self = self else { fatalError() }
                    return DetailsViewController(mantra: mantra,
                                                 mode: .add,
                                                 position: self.overallMantraCount,
                                                 mantraTitles: self.overallMantraTitles,
                                                 delegate: self, coder: coder)
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
        getCurrentMantrasInfo()
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
        var isDuplicating = false
        if overallMantraTitles.contains(title) {
            isDuplicating = true
        }
        return isDuplicating
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
        addPreloadedMantra()
        coreDataManager.saveContext()
        applySnapshot()
        dismissPreloadedMantraPickerState()
        
        if !isInFavoriteMode {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                let indexPath = IndexPath(row: self.dataSource.snapshot().numberOfItems-1, section: 0)
                self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
            }
        }
    }
    
    private func addPreloadedMantra() {
        let selectedMantraNumber = mantraPicker.selectedRow(inComponent: 0)
        let mantra = Mantra(context: context)
        let preloadedMantra = sortedInitialMantraData[selectedMantraNumber]
        mantra.position = Int32(overallMantraCount)
        mantra.title = preloadedMantra[.title]
        mantra.text = preloadedMantra[.text]
        mantra.details = preloadedMantra[.details]
        mantra.image = UIImage(named: preloadedMantra[.image] ?? Constants.defaultImage)?.pngData()
        mantra.imageForTableView = UIImage(named: preloadedMantra[.image] ?? Constants.defaultImage)?
            .resize(to: CGSize(width: Constants.rowHeight,
                                   height: Constants.rowHeight))?.pngData()
    }
    
    private func dismissPreloadedMantraPickerState() {
        coverView?.removeFromSuperview()
        coverView = nil
        mantraPickerTextField.resignFirstResponder()
        navigationController?.navigationBar.tintColor = nil
    }
}

//MARK: - Load Mantras

extension MantraViewController {
    
    private func loadMantras(with request: NSFetchRequest<Mantra> = Mantra.fetchRequest(),
                             predicate: NSPredicate? = nil,
                             animatingDifferences: Bool = true) {
        
        request.sortDescriptors = isInFavoriteMode ?
            [NSSortDescriptor(key: "positionFavorite", ascending: true)] :
            [NSSortDescriptor(key: "position", ascending: true)]
        
        let favoritePredicate = NSPredicate(format: "isFavorite = %d", true)
        if let additionalPredicate = predicate {
            request.predicate = additionalPredicate
        }
        if isInFavoriteMode {
            request.predicate = favoritePredicate
        }
        if let additionalPredicate = predicate, isInFavoriteMode {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [favoritePredicate, additionalPredicate])
        }
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: context,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
            applySnapshot(animatingDifferences: animatingDifferences)
        } catch {
            print("Error fetching data \(error)")
        }
    }
}

// MARK: - NSFetchedResultsController Delegate

extension MantraViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        reloadDataSource()
        applySnapshot()
        widgetManager.updateWidgetData()
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
            loadMantras()
            return
        }
        let request: NSFetchRequest<Mantra> = Mantra.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", text)
        loadMantras(with: request, predicate: predicate)
    }
}

//MARK: - PickerView Delegate, PickerView DataSource

extension MantraViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        sortedInitialMantraData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        sortedInitialMantraData[row][.title]
    }
}

//MARK: - ReadsCountViewController Delegate (Handle Favorite Action and Updating Widget)

extension MantraViewController: ReadsCountViewControllerDelegate {
    
    func favoriteActionPerformed() {
        reorderFavoriteMantraPositionsForDeleting(withSnapshot: dataSource.snapshot())
    }
}

//MARK: - DetailsViewController Delegate (Load Mantras With Quantity Check)

extension MantraViewController: DetailsViewControllerDelegate {
    
    func updateView() {
        loadMantras()
        getCurrentMantrasInfo()
        if !isInFavoriteMode && currentMantraCount < overallMantraCount {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
                let indexPath = IndexPath(row: self.dataSource.snapshot().numberOfItems-1, section: 0)
                self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
}

//MARK: - OnboardingViewController

extension MantraViewController {
    
    private func setupBlurEffectView() {
        navigationController?.view.addSubview(blurEffectView)
        blurEffectView.frame = UIScreen.main.bounds
        blurEffectView.alpha = 0
    }
    
    private func animateBlurEffectViewIn() {
        UIView.animate(withDuration: 0.5) {
            self.blurEffectView.alpha =  1
        }
    }
    
    private func animateBlurEffectViewOut() {
        UIView.animate(withDuration: 0.8) {
            self.blurEffectView.alpha = 0
        } completion: { _ in
            self.blurEffectView.removeFromSuperview()
        }
    }
}

//MARK: - OnboardingViewController Delegate

extension MantraViewController: OnboardingViewControllerDelegate {
    
    func dismissButtonPressed() {
        animateBlurEffectViewOut()
        wasShownOnboardingAlert.toggle()
    }
}
