//
//  MantraTableViewController.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 30.07.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit
import CoreData

class MantraTableViewController: UITableViewController {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let defaults = UserDefaults.standard
    private var isInFavoriteMode: Bool {
        get { defaults.bool(forKey: "isInFavoriteMode") }
        set { defaults.set(newValue, forKey: "isInFavoriteMode") }
    }
    
    private let segmentedControl = UISegmentedControl(items: [NSLocalizedString("All", comment: "Segment Title on MantraTableViewController"),
                                                              UIImage(systemName: "star") ?? ""])
    
    private var mantraArray: [Mantra] = []
    private var currentMantraCount = 0
    private var currentFavoriteMantraCount = 0
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var mantraPicker = UIPickerView()
    private lazy var mantraPickerTextField = UITextField(frame: .zero)
    private var coverView: UIView?
    private lazy var sortedInitialMantraData = InitialMantra.data.sorted {
        guard
            let mantraTitle0 = $0[.title],
            let mantraTitle1 = $1[.title]
        else { return false }
        return mantraTitle0 < mantraTitle1
    }
    
    private var overallMantraArray: [Mantra] {
        var array: [Mantra] = []
        let request: NSFetchRequest<Mantra> = Mantra.fetchRequest()
        do {
            array = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        return array
    }
    
    private var favoriteMantraArray: [Mantra] {
        var array: [Mantra] = []
        let request: NSFetchRequest<Mantra> = Mantra.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "positionFavorite", ascending: true)]
        request.predicate = NSPredicate(format: "isFavorite = %d", true)
        do {
            array = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        return array
    }
    
    private lazy var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let blurredView = UIVisualEffectView(effect: blurEffect)
        return blurredView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForOnboardingAlert()
        
        if let lastFavoritePosition = favoriteMantraArray.last?.positionFavorite, lastFavoritePosition >= favoriteMantraArray.count {
            currentFavoriteMantraCount = favoriteMantraArray.count
            reorderFavoriteMantraPositionsForFavoritingUnfavoritingDeleting()
        }
        
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 60
        
        setupNavigationBar()
        setupSearchController()
        
        loadMantras()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        setupSegmentedControl()
        
        if currentFavoriteMantraCount != favoriteMantraArray.count {
            currentFavoriteMantraCount = favoriteMantraArray.count
            reorderFavoriteMantraPositionsForFavoritingUnfavoritingDeleting()
            saveMantras()
        }
        
        if searchController.isActive {
            performSearch()
        } else {
            loadMantras()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] (context) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.setupSegmentedControl()
                self.coverView?.frame = UIScreen.main.bounds
                if !self.defaults.bool(forKey: "wasShownOnboardingAlert") {
                    self.blurEffectView.frame = UIScreen.main.bounds
                }
            }
        })
    }
    
    @objc private func handleCoverTap(_ sender: UITapGestureRecognizer? = nil) {
        dismissPreloadedMantraPickerState()
    }
    
    private func checkForOnboardingAlert() {
        let wasShownOnboardingAlert = defaults.bool(forKey: "wasShownOnboardingAlert")
        if !wasShownOnboardingAlert {
            setupBlurEffectView()
            animateBlurEffectViewIn()
            if let onboardingController = storyboard?.instantiateViewController(identifier: Constants.onboardingController) as? OnboardingController {
                onboardingController.delegate = self
                onboardingController.modalTransitionStyle = .crossDissolve
                present(onboardingController, animated: true)
            }
        }
    }
    
    
    //MARK: - ViewDidLoad Setup
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.titleView = segmentedControl
        
        navigationItem.title = NSLocalizedString("Mantra Counter", comment: "App name")
        navigationItem.searchController = searchController
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
        
        let newMantraAction = UIAction(title: NSLocalizedString("New Mantra", comment: "Menu Item on MantraTableViewController"),
                                       image: UIImage(systemName: "square.and.pencil")) { [weak self] (action) in
            guard let self = self else { return }
            self.showNewMantraVC()
        }
        let preloadedMantraAction = UIAction(title: NSLocalizedString("Preloaded Mantra", comment: "Menu Item on MantraTableViewController"),
                                             image: UIImage(systemName: "books.vertical")) { [weak self] (action) in
            guard let self = self else { return }
            self.setPreloadedMantraPickerState()
        }
        let addingMenu = UIMenu(children: [newMantraAction, preloadedMantraAction])
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .add, primaryAction: nil, menu: addingMenu)
    }
    
    private func setupSegmentedControl() {
        segmentedControl.selectedSegmentIndex = isInFavoriteMode ? 1 : 0
        segmentedControl.addTarget(self, action: #selector(segmentedValueChanged), for: .valueChanged)
        segmentedControl.setWidth(view.frame.size.width/6, forSegmentAt: 0)
        segmentedControl.setWidth(view.frame.size.width/6, forSegmentAt: 1)
        segmentedControl.sizeToFit()
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search", comment: "Search Placeholder")
        searchController.definesPresentationContext = true
    }
    
    @objc private func segmentedValueChanged(_ sender: UISegmentedControl) {
        isInFavoriteMode = !isInFavoriteMode
        loadMantras(withAnimation: true)
    }
    
    //MARK: - NavigationBar Buttons Actions
    
    @objc private func editButtonPressed() {
        setEditing(true, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
    }
    
    @objc private func doneButtonPressed() {
        setEditing(false, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
    }
    
    //MARK: - Home Screen Quick Actions Handling
    
    func setFavoriteMode() {
        isInFavoriteMode = true
    }
    
    func setAddNewMantraMode() {
        showNewMantraVC()
    }
    
    func setSearchMode() {
        isInFavoriteMode = false
        defaults.set(isInFavoriteMode, forKey: "inFavoriteMode")
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
    
    // MARK: - TableView DataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mantraArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.mantraCellID, for: indexPath)
        let mantra = mantraArray[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = mantra.title
        
        if (content.text != nil) {
            content.secondaryText = NSLocalizedString("Current readings count:", comment: "Current readings count") + " \(mantra.reads)"
            content.secondaryTextProperties.color = .secondaryLabel
            content.textToSecondaryTextVerticalPadding = 4
            content.image = (mantra.imageForTableView != nil) ? UIImage(data: mantra.imageForTableView!) : UIImage(named: Constants.defaultImage_tableView)
        }
        cell.accessoryType = .disclosureIndicator
        cell.contentConfiguration = content
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        !searchController.isActive
    }
    
    // Swipe Actions
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "") { [weak self] (contextualAction, view, isToDismiss) in
            guard let self = self else { return }
            self.deleteConfirmationAlert(for: indexPath)
            isToDismiss(true)                                                                                                       
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        let star = mantraArray[indexPath.row].isFavorite ? "star.slash" : "star"
        let favoriteAction = UIContextualAction(style: .normal,
                                                title: "") { [weak self] (contextualAction, view, isToDismiss) in
            guard let self = self else { return }
            isToDismiss(true)
            self.handleFavoriteAction(for: indexPath)
        }
        favoriteAction.backgroundColor = .systemBlue
        favoriteAction.image = UIImage(systemName: star)
        
        let actions = isInFavoriteMode ? [favoriteAction] : [deleteAction, favoriteAction]
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    // Moving rows
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        guard sourceIndexPath != destinationIndexPath else { return }
        
        let movedMantra = mantraArray[sourceIndexPath.row]
        mantraArray.remove(at: sourceIndexPath.row)
        mantraArray.insert(movedMantra, at: destinationIndexPath.row)
        
        reorderMantraPositionsForMovingDeleting()
        saveMantras()
    }
    
    // Go To ReadsCountViewController
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentFavoriteMantraCount = favoriteMantraArray.count
        let mantra = mantraArray[indexPath.row]
        guard let readsCountViewController = storyboard?.instantiateViewController(
                identifier: Constants.readsCountViewControllerID,
                creator: { [weak self] coder in
                    guard let self = self else { fatalError() }
                    return ReadsCountViewController(mantra: mantra,
                                                    positionFavorite: Int32(self.currentFavoriteMantraCount),
                                                    coder: coder)
                }) else { return }
        navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Mantra List", comment: "Back button of MantraTableViewController"), style: .plain, target: nil, action: nil)
        show(readsCountViewController, sender: true)
    }
    
    // Contextual Menu For Row
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let title = mantraArray[indexPath.row].isFavorite ? NSLocalizedString("Unfavorite", comment: "Menu Action on MantraTableViewController") : NSLocalizedString("Favorite", comment: "Menu Action on MantraTableViewController")
        let image = mantraArray[indexPath.row].isFavorite ? UIImage(systemName: "star.slash") : UIImage(systemName: "star")
        
        let favorite = UIAction(title: title, image: image) { [weak self] _ in
            guard let self = self else { return }
            self.handleFavoriteAction(for: indexPath)
        }
        
        let delete = UIAction(title: NSLocalizedString("Delete", comment: "Menu Action on MantraTableViewController"),
                              image: UIImage(systemName: "trash"),
                              attributes: [.destructive]) { [weak self] action in
            guard let self = self else { return }
            self.deleteConfirmationAlert(for: indexPath)
        }
        
        let children = isInFavoriteMode ? [favorite] : [favorite, delete]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) {_ in
            UIMenu(children: children)
        }
    }
    
    //MARK: - Cells Manipulation Methods
    
    private func deleteConfirmationAlert(for indexPath: IndexPath) {
        let alert = UIAlertController(title: nil,
                                      message: NSLocalizedString("Are you sure you want to delete this mantra?", comment: "Alert Message on MantraTableViewController"),
                                      preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", comment: "Alert Button on MantraTableViewController"),
                                         style: .destructive) { [weak self] (action) in
            guard let self = self else { return }
            self.deleteMantra(for: indexPath)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert Button on MantraTableViewController"),
                                         style: .default, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func deleteMantra(for indexPath: IndexPath) {
        context.delete(mantraArray[indexPath.row])
        mantraArray.remove(at: indexPath.row)
        reorderMantraPositionsForMovingDeleting()
        reorderFavoriteMantraPositionsForFavoritingUnfavoritingDeleting()
        saveMantras()
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    private func handleFavoriteAction(for indexPath: IndexPath) {
        mantraArray[indexPath.row].isFavorite = !mantraArray[indexPath.row].isFavorite
        mantraArray[indexPath.row].positionFavorite = mantraArray[indexPath.row].isFavorite ? Int32(favoriteMantraArray.count) : Int32(0)
        reorderFavoriteMantraPositionsForFavoritingUnfavoritingDeleting()
        saveMantras()
        if isInFavoriteMode {
            mantraArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    private func reorderMantraPositionsForMovingDeleting() {
        for i in 0..<mantraArray.count {
            if isInFavoriteMode {
                mantraArray[i].positionFavorite = Int32(i)
            } else {
                mantraArray[i].position = Int32(i)
            }
        }
    }
    
    private func reorderFavoriteMantraPositionsForFavoritingUnfavoritingDeleting() {
        for i in 0..<favoriteMantraArray.count {
            favoriteMantraArray[i].positionFavorite = Int32(i)
        }
    }
    
    //MARK: - Add Mantra Stack
    
    private func showNewMantraVC() {
        currentMantraCount = overallMantraArray.count
        let mantra = Mantra(context: context)
        guard let detailsViewController = storyboard?.instantiateViewController(
                identifier: Constants.detailsViewControllerID,
                creator: { [weak self] coder in
                    guard let self = self else { fatalError() }
                    return DetailsViewController(mantra: mantra,
                                                 mode: .add,
                                                 position: self.currentMantraCount,
                                                 mantraTitles: self.overallMantraArray.compactMap{$0.title},
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
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePreloadedMantraButtonPressed))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPreloadedMantraButtonPressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        tableView.addSubview(mantraPickerTextField)
        
        mantraPickerTextField.inputView = mantraPicker
        mantraPickerTextField.inputAccessoryView = toolBar
        mantraPicker.selectRow(0, inComponent: 0, animated: false)
        mantraPickerTextField.becomeFirstResponder()
    }
    
    @objc private func cancelPreloadedMantraButtonPressed() {
        dismissPreloadedMantraPickerState()
    }
    
    @objc private func donePreloadedMantraButtonPressed() {
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
        let title = sortedInitialMantraData[selectedMantraNumber][.title]
        var isDuplicating = false
        if (overallMantraArray.map{$0.title}).contains(title) {
            isDuplicating = true
        }
        return isDuplicating
    }
    
    private func showDuplicatingAlert() {
        let alert = UIAlertController(title: nil,
                                      message: NSLocalizedString("It's already in your mantra list. Add another one?", comment: "Alert Message for Duplication"),
                                      preferredStyle: .alert)
        let addAction = UIAlertAction(title: NSLocalizedString("Add", comment: "Alert Button on MantraTableViewController"),
                                      style: .default) { [weak self] (action) in
            guard let self = self else { return }
            self.handleAddPreloadedMantra()
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert Button on MantraTableViewController"),
                                         style: .default) { [weak self] (action) in
            guard let self = self else { return }
            self.dismissPreloadedMantraPickerState()
        }
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func handleAddPreloadedMantra() {
        addPreloadedMantra()
        saveMantras()
        loadMantras()
        if !isInFavoriteMode {
            let indexPath = IndexPath(row: overallMantraArray.count-1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
        dismissPreloadedMantraPickerState()
    }
    
    private func addPreloadedMantra() {
        let selectedMantraNumber = mantraPicker.selectedRow(inComponent: 0)
        let mantra = Mantra(context: context)
        let preloadedMantra = sortedInitialMantraData[selectedMantraNumber]
        mantra.position = Int32(overallMantraArray.count-1)
        mantra.title = preloadedMantra[.title]
        mantra.text = preloadedMantra[.text]
        mantra.details = preloadedMantra[.details]
        mantra.image = UIImage(named: preloadedMantra[.image] ?? Constants.defaultImage)?.pngData()
        mantra.imageForTableView = UIImage(named: preloadedMantra[.imageForTableView] ?? Constants.defaultImage_tableView)?.pngData()
    }
    
    private func dismissPreloadedMantraPickerState() {
        coverView?.removeFromSuperview()
        coverView = nil
        mantraPickerTextField.resignFirstResponder()
        navigationController?.navigationBar.tintColor = nil
    }
    
    //MARK: - Core Data Manipulation
    
    private func loadMantras(with request: NSFetchRequest<Mantra> = Mantra.fetchRequest(), predicate: NSPredicate? = nil, withAnimation: Bool = false) {
        
        request.sortDescriptors = isInFavoriteMode ? [NSSortDescriptor(key: "positionFavorite", ascending: true)] : [NSSortDescriptor(key: "position", ascending: true)]
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
        
        do {
            mantraArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        if withAnimation {
            tableView.reloadSections([0], with: .automatic)
        } else {
            tableView.reloadData()
        }
    }
    
    private func saveMantras() {
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
    }
}

//MARK: - PickerView Delegate, PickerView DataSource

extension MantraTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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


// MARK: - UISearchResultsUpdating Delegate

extension MantraTableViewController: UISearchResultsUpdating {
    
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

//MARK: - DetailsViewController Delegate (Load Mantras With Quantity Check)

extension MantraTableViewController: DetailsViewControllerDelegate {
    
    func updateView() {
        if currentMantraCount < overallMantraArray.count {
            currentMantraCount = overallMantraArray.count
            loadMantras()
            if !isInFavoriteMode {
                let indexPath = IndexPath(row: currentMantraCount-1, section: 0)
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        } else {
            loadMantras()
        }
    }
}

//MARK: - OnboardingController

extension MantraTableViewController {
    
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
        } completion: { (_) in
            self.blurEffectView.removeFromSuperview()
        }
    }
}

//MARK: - OnboardingController Delegate

extension MantraTableViewController: OnboardingControllerDelegate {
    
    func dismissButtonPressed() {
        animateBlurEffectViewOut()
        defaults.set(true, forKey: "wasShownOnboardingAlert")
    }
}
