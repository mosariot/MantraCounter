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
    
    private var mantraArray = [Mantra]()
    private var currentMantrasQuantity = 0
    private lazy var mantraPicker = UIPickerView()
    private lazy var mantraPickerTextField = UITextField(frame: CGRect.zero)
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        navigationItem.title = NSLocalizedString("Mantra Counter", comment: "App name")
        
        loadMantras()
        currentMantrasQuantity = mantraArray.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadMantras()
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
        cell.detailTextLabel?.textColor = .systemGray
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
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            reorderMantraPositionsForDeleteAction(deletingPosition: indexPath.row)
            context.delete(mantraArray[indexPath.row])
            saveMantras()
            
            mantraArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
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
    
    private func reorderMantraPositionsForDeleteAction(deletingPosition: Int) {
        
        guard deletingPosition+1 < mantraArray.count else { return }
        
        for i in (deletingPosition+1)...(mantraArray.count-1) {
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
                return DetailsViewController(mantra: mantra, mode: .add, position: self.mantraArray.count, delegate: self, coder: coder)
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
        
        // make custom toolbar
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
            duplicatingAlert()
        } else {
            handleAddPreloadedMantra()
        }
    }
    
    private func isMantraDuplicating() -> Bool {
        let selectedMantraNumber = mantraPicker.selectedRow(inComponent: 0)
        var isDuplicating = false
        mantraArray.forEach { (mantra) in
            if mantra.title == InitialMantra.data[selectedMantraNumber][.title] {
                isDuplicating = true
            }
        }
        return isDuplicating
    }
    
    private func duplicatingAlert() {
        
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
        saveMantras()
        tableView.reloadData()
        let indexPath = IndexPath(row: mantraArray.count-1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        dismissPreloadedMantraPickerState()
    }
    
    private func addPreloadedMantra() {
        
        let selectedMantraNumber = mantraPicker.selectedRow(inComponent: 0)
        let mantra = Mantra(context: context)
        let preloadedMantra = InitialMantra.data[selectedMantraNumber]
        mantra.position = Int32(mantraArray.count)
        mantra.title = preloadedMantra[.title]
        mantra.text = preloadedMantra[.text]
        mantra.details = preloadedMantra[.details]
        mantra.image = UIImage(named: preloadedMantra[.image] ?? K.defaultImage)?.pngData()
        mantra.imageForTableView = UIImage(named: preloadedMantra[.imageForTableView] ?? K.defaultImage_tableView)?.pngData()
        mantraArray.append(mantra)
    }

    private func dismissPreloadedMantraPickerState() {
        mantraPickerTextField.resignFirstResponder()
        navigationItem.rightBarButtonItem?.isEnabled = true
        navigationItem.leftBarButtonItem?.isEnabled = true
        tableView.isScrollEnabled = true
    }
    
    //MARK: - Table Edit Buttons Actions
    
    @objc func doneButtonPressed() {
        setEditing(false, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
    }
    
    @objc func editButtonPressed() {
        setEditing(true, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
    }
    
    //MARK: - Model Manipulation
    
    private func loadMantras() {
        
        let request: NSFetchRequest<Mantra> = Mantra.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "position", ascending: true)]
        do {
            mantraArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
    
    private func saveMantras() {
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
    }
}

//MARK: - DetailsViewController Delegate (Load Mantras With Quantity Check)

extension MantraTableViewController: DetailsViewControllerDelegate {
    
    func updateView() {
        loadMantras()
        if currentMantrasQuantity < mantraArray.count {
            let indexPath = IndexPath(row: mantraArray.count-1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
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
