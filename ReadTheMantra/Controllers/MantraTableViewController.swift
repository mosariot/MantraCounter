//
//  MantraTableViewController.swift
//  ReadTheMantra
//
//  Created by Александр Воробьев on 30.07.2020.
//  Copyright © 2020 Александр Воробьев. All rights reserved.
//

import UIKit
import CoreData

class MantraTableViewController: UITableViewController {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let defaults = UserDefaults.standard
    private var inFavoriteMode = false
    
    private var mantraArray = [Mantra]()
    private var currentMantraCount = 0
    
    private let segmentedControl = UISegmentedControl(items: [NSLocalizedString("All", comment: "Segment Title on MantraTableViewController"),
                                                              UIImage(systemName: "star") as Any])
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var mantraPicker = UIPickerView()
    private lazy var mantraPickerTextField = UITextField(frame: CGRect.zero)
    
    private var overallMantraArray: [Mantra] {
        var array = [Mantra]()
        let request: NSFetchRequest<Mantra> = Mantra.fetchRequest()
        do {
            array = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        return array
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentMantraCount = overallMantraArray.count
        
        inFavoriteMode = defaults.bool(forKey: "inFavoriteMode")
        setupNavigationBar()
        setupSegmentedControl()
        setupSearchController()

        loadMantras()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if searchController.isActive {
            performSearch()
        } else {
            loadMantras()
        }
    }
    
    //MARK: - ViewDidLoad Setup
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = NSLocalizedString("Mantra Counter", comment: "App name")
        navigationItem.searchController = searchController
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        setEditButton()
    }
    
    private func setEditButton() {
        navigationItem.leftBarButtonItem = inFavoriteMode ? nil : UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
    }
    
    private func setupSegmentedControl() {
        segmentedControl.selectedSegmentIndex = inFavoriteMode ? 1 : 0
        segmentedControl.setWidth(view.frame.size.width/5, forSegmentAt: 0)
        segmentedControl.setWidth(view.frame.size.width/5, forSegmentAt: 1)
        segmentedControl.addTarget(self, action: #selector(segmentedValueChanged), for: .valueChanged)
        navigationItem.titleView = segmentedControl
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search", comment: "Search Placeholder")
        searchController.searchBar.delegate = self
        searchController.definesPresentationContext = true
    }
    
    @objc private func segmentedValueChanged(_ sender: UISegmentedControl) {
        inFavoriteMode = !inFavoriteMode
        defaults.set(inFavoriteMode, forKey: "inFavoriteMode")
        setEditButton()
        loadMantras(withAnimation: true)
    }
    
    // MARK: - TableView DataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mantraArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.mantraCellID, for: indexPath)
        let mantra = mantraArray[indexPath.row]
        cell.textLabel?.text = mantra.title
        cell.detailTextLabel?.text = NSLocalizedString("Current readings count:", comment: "Current readings count") + " \(mantra.reads)"
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.imageView?.image = imageForCell(for: mantra)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    private func imageForCell(for mantra: Mantra) -> UIImage? {
        if let imageData = mantra.imageForTableView {
            return UIImage(data: imageData)
        } else {
            return UIImage(named: K.defaultImage_tableView)
        }
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        !searchController.isActive
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "") { [weak self] (contextualAction, view, isToDismiss) in
            self?.deleteConfirmationAlert(for: indexPath)
            isToDismiss(true)                                                                                                       
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        let star = mantraArray[indexPath.row].isFavorite ? "star.slash" : "star"
        let favoriteAction = UIContextualAction(style: .normal,
                                                title: "") { [weak self] (contextualAction, view, isToDismiss) in
            self?.handleFavoriteAction(for: indexPath)
            isToDismiss(true)
        }
        favoriteAction.backgroundColor = .systemBlue
        favoriteAction.image = UIImage(systemName: star)
        
        let actions = inFavoriteMode ? [favoriteAction] : [deleteAction, favoriteAction]
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        guard sourceIndexPath != destinationIndexPath else { return }
        
        reorderMantraPositionsForMovingAction(from: sourceIndexPath.row, to: destinationIndexPath.row)
        saveMantras()
        
        let movedMantra = mantraArray[sourceIndexPath.row]
        mantraArray.remove(at: sourceIndexPath.row)
        mantraArray.insert(movedMantra, at: destinationIndexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mantra = mantraArray[indexPath.row]
        guard let readsCountViewController = storyboard?.instantiateViewController(
                identifier: K.readsCountViewControllerID,
                creator: { coder in
                    ReadsCountViewController(mantra: mantra, coder: coder)
                }) else { return }
        show(readsCountViewController, sender: true)
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if mantraPickerTextField.isFirstResponder {
            dismissPreloadedMantraPickerState()
            return false
        } else {
            return true
        }
    }
    
    //MARK: - Cells Manipulation Methods
    
    private func deleteConfirmationAlert(for indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: NSLocalizedString("Are you sure you want to delete this mantra?", comment: "Alert Message on MantraTableViewController"), preferredStyle: .alert)
        let addAction = UIAlertAction(title: NSLocalizedString("Delete", comment: "Alert Button on MantraTableViewController"), style: .default) { [weak self] (action) in
            self?.deleteMantra(for: indexPath)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert Button on MantraTableViewController"), style: .destructive) { [weak self] (action) in
            self?.dismissPreloadedMantraPickerState()
        }
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func deleteMantra(for indexPath: IndexPath) {
        reorderMantraPositionsForDeleteAction(deletingPosition: indexPath.row)
        context.delete(mantraArray[indexPath.row])
        saveMantras()
        
        mantraArray.remove(at: indexPath.row)
        currentMantraCount -= 1
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    private func handleFavoriteAction(for indexPath: IndexPath) {
        mantraArray[indexPath.row].isFavorite = !mantraArray[indexPath.row].isFavorite
        saveMantras()
        if inFavoriteMode {
            mantraArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    private func reorderMantraPositionsForDeleteAction(deletingPosition: Int) {
        guard deletingPosition+1 < currentMantraCount else { return }
        for i in (deletingPosition+1)...(currentMantraCount-1) {
            mantraArray[i].position -= 1
        }
    }
    
    private func reorderMantraPositionsForMovingAction(from source: Int, to destination: Int) {
        let reorderIndexDifference = source - destination
        switch reorderIndexDifference {
        case 1...:
            for i in (destination)...(source-1) {
                mantraArray[i].position += 1
            }
        case ...(-1):
            for i in (source+1)...(destination) {
                mantraArray[i].position -= 1
            }
        default:
            return
        }
        mantraArray[source].position = Int32(destination)
    }
    
    //MARK: - Add Mantra Stack
    
    @objc private func addButtonPressed() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let addNewMantraAction = UIAlertAction(title: NSLocalizedString("New Mantra", comment: "Alert Title on MantraTableViewController"),
                                               style: .default) { [weak self] (action) in
            self?.showNewMantraVC()
        }
        let addPreloadedMantraAction = UIAlertAction(title: NSLocalizedString("Preloaded Mantra", comment: "Alert Title on MantraTableViewController"),
                                                     style: .default) { [weak self] (action) in
            self?.setPreloadedMantraPickerState()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(addNewMantraAction)
        alert.addAction(addPreloadedMantraAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func showNewMantraVC() {
        let mantra = Mantra(context: context)
        guard let detailsViewController = storyboard?.instantiateViewController(
                identifier: K.detailsViewControllerID,
                creator: { [weak self] coder in
                    guard let self = self else { fatalError() }
                    return DetailsViewController(mantra: mantra, mode: .add, position: self.currentMantraCount, mantraTitles: self.overallMantraArray.map { $0.title }, delegate: self, coder: coder)
                }) else { return }
        let navigationController = UINavigationController(rootViewController: detailsViewController)
        present(navigationController, animated: true)
    }
    
    private func setPreloadedMantraPickerState() {
        makeAndShowMantraPickerView()
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.leftBarButtonItem?.isEnabled = false
        tableView.isScrollEnabled = false
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
            showDuplicatingAlert()
        } else {
            handleAddPreloadedMantra()
        }
    }
    
    private func isMantraDuplicating() -> Bool {
        let selectedMantraNumber = mantraPicker.selectedRow(inComponent: 0)
        var isDuplicating = false
        overallMantraArray.forEach { (mantra) in
            if mantra.title == InitialMantra.data[selectedMantraNumber][.title] {
                isDuplicating = true
            }
        }
        return isDuplicating
    }
    
    private func showDuplicatingAlert() {
        let alert = UIAlertController(title: nil, message: NSLocalizedString("It's already in your mantra list. Add another one?", comment: "Alert Message on MantraTableViewController"), preferredStyle: .alert)
        let addAction = UIAlertAction(title: NSLocalizedString("Add", comment: "Alert Button on MantraTableViewController"), style: .default) { [weak self] (action) in
            self?.handleAddPreloadedMantra()
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert Button on MantraTableViewController"), style: .destructive) { [weak self] (action) in
            self?.dismissPreloadedMantraPickerState()
        }
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func handleAddPreloadedMantra() {
        addPreloadedMantra()
        currentMantraCount += 1
        saveMantras()
        loadMantras()
        if !inFavoriteMode {
            let indexPath = IndexPath(row: currentMantraCount-1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
        dismissPreloadedMantraPickerState()
    }
    
    private func addPreloadedMantra() {
        let selectedMantraNumber = mantraPicker.selectedRow(inComponent: 0)
        let mantra = Mantra(context: context)
        let preloadedMantra = InitialMantra.data[selectedMantraNumber]
        mantra.position = Int32(currentMantraCount)
        mantra.title = preloadedMantra[.title]
        mantra.text = preloadedMantra[.text]
        mantra.details = preloadedMantra[.details]
        mantra.image = UIImage(named: preloadedMantra[.image] ?? K.defaultImage)?.pngData()
        mantra.imageForTableView = UIImage(named: preloadedMantra[.imageForTableView] ?? K.defaultImage_tableView)?.pngData()
    }
    
    private func dismissPreloadedMantraPickerState() {
        mantraPickerTextField.resignFirstResponder()
        navigationItem.rightBarButtonItem?.isEnabled = true
        navigationItem.leftBarButtonItem?.isEnabled = true
        tableView.isScrollEnabled = true
    }
    
    //MARK: - Table Edit Buttons Actions
    
    @objc private func doneButtonPressed() {
        setEditing(false, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
    }
    
    @objc private func editButtonPressed() {
        setEditing(true, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
    }
    
    //MARK: - Core Data Manipulation
    
    private func loadMantras(with request: NSFetchRequest<Mantra> = Mantra.fetchRequest(), predicate: NSPredicate? = nil, withAnimation: Bool = false) {
        
        request.sortDescriptors = [NSSortDescriptor(key: "position", ascending: true)]
        let favoritePredicate = NSPredicate(format: "isFavorite = %d", true)
        if let additionalPredicate = predicate {
            request.predicate = additionalPredicate
        }
        if inFavoriteMode {
            request.predicate = favoritePredicate
        }
        if let additionalPredicate = predicate, inFavoriteMode {
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
        InitialMantra.data.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        InitialMantra.data[row][.title]
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
        print(text)
        
        loadMantras(with: request, predicate: predicate)
    }
}

// MARK: - UISearchBar Delegate

extension MantraTableViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if mantraPickerTextField.isFirstResponder {
            dismissPreloadedMantraPickerState()
        }
        return true
    }
}

//MARK: - DetailsViewController Delegate (Load Mantras With Quantity Check)

extension MantraTableViewController: DetailsViewControllerDelegate {
    
    func updateView() {
        if currentMantraCount < overallMantraArray.count {
            currentMantraCount = overallMantraArray.count
            loadMantras()
            if !inFavoriteMode {
                let indexPath = IndexPath(row: currentMantraCount-1, section: 0)
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        } else {
            loadMantras()
    }
}
