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
    private lazy var mantraPicker = UIPickerView()
    private lazy var mantraPickerTextField = UITextField(frame: CGRect.zero)
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        navigationItem.title = NSLocalizedString("Mantra Counter", comment: "App name")
        
        loadMantras()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setInitialBarButtonsState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadMantras()
    }
    
    func setInitialBarButtonsState() {
        navigationItem.rightBarButtonItem?.isEnabled = true
        navigationItem.leftBarButtonItem?.isEnabled = true
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
        
        if let imageData = mantra.image {
            cell.imageView?.image = UIImage(data: imageData)
        } else {
            cell.imageView?.image = UIImage(named: K.defaultImage_320)
        }
        
        cell.accessoryType = .disclosureIndicator
        return cell
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
            mantraPickerTextField.resignFirstResponder()
            mantraPicker.selectRow(0, inComponent: 0, animated: false)
            setInitialBarButtonsState()
            return false
        } else {
            return true
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if mantraPickerTextField.isFirstResponder {
            mantraPickerTextField.resignFirstResponder()
            mantraPicker.selectRow(0, inComponent: 0, animated: false)
            setInitialBarButtonsState()
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
                return DetailsViewController(mantra: mantra, mode: .edit, position: self.mantraArray.count, coder: coder)
        }) else { return }
        show(detailsViewController, sender: self)
    }
    
    private func setPreloadedMantraPickerState() {
        makeAndShowMantraPickerView()
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.leftBarButtonItem?.isEnabled = false
    }
    
    private func makeAndShowMantraPickerView() {
        
        mantraPicker.dataSource = self
        mantraPicker.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
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
        mantraPickerTextField.becomeFirstResponder()
    }
    
    @objc private func cancelPreloadedMantraButtonPressed() {
        mantraPickerTextField.resignFirstResponder()
        mantraPicker.selectRow(0, inComponent: 0, animated: false)
        setInitialBarButtonsState()
    }
    
    @objc private func donePreloadedMantraButtonPressed() {
        mantraPickerTextField.resignFirstResponder()
        setInitialBarButtonsState()
        if isMantraDuplicating() {
            duplicatingAlert()
        } else {
            addPreloadedMantra()
            mantraPicker.selectRow(0, inComponent: 0, animated: false)
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
        let alert = UIAlertController(title: "", message: NSLocalizedString("This mantra is already in your list. Add another one?", comment: "Alert Message on MantraTableViewController"), preferredStyle: .alert)
        let addAction = UIAlertAction(title: NSLocalizedString("Add", comment: "Alert Button on MantraTableViewController"), style: .default) { [weak self] (action) in
            self?.addPreloadedMantra()
            self?.mantraPicker.selectRow(0, inComponent: 0, animated: false)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert Button on MantraTableViewController"), style: .destructive) { [weak self] (action) in
            self?.setPreloadedMantraPickerState()
        }
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func addPreloadedMantra() {
        
        let selectedMantraNumber = mantraPicker.selectedRow(inComponent: 0)
        let mantra = Mantra(context: context)
        let preloadedMantra = InitialMantra.data[selectedMantraNumber]
        mantra.position = Int32(mantraArray.count)
        mantra.title = preloadedMantra[.title]
        mantra.text = preloadedMantra[.text]
        mantra.details = preloadedMantra[.details]
        mantra.image = UIImage(named: preloadedMantra[.image] ?? K.defaultImage_320)?.pngData()
        mantraArray.append(mantra)
        saveMantras()
        tableView.reloadData()
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
        context.reset()
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
