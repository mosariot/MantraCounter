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
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        loadMantras()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(addNewMantraButtonPressed))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadMantras()
    }
    
    // MARK: - TableView DataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mantraArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MantraCell", for: indexPath)
        let mantra = mantraArray[indexPath.row]
        cell.textLabel?.text = mantra.title
        let currentReadingsCount = NSLocalizedString("Current readings count:", comment: "Current readings count")
        cell.detailTextLabel?.text = currentReadingsCount + " \(mantra.reads)"
        cell.detailTextLabel?.textColor = .systemGray

        if let imageData = mantra.image {
            cell.imageView?.image = UIImage(data: imageData)
        } else {
            cell.imageView?.image = UIImage(named: "kid_160")
        }
        
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    //MARK: - TableView Delegate
      
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
            identifier: "ReadsCountViewController",
            creator: { coder in
                ReadsCountViewController(mantra: mantra, coder: coder)
        }) else { return }
        navigationController?.pushViewController(readsCountViewController, animated: true)
    }
    
    //MARK: - Action Methods
       
    @objc func addNewMantraButtonPressed() {
        let mantra = Mantra(context: context)
        guard let detailsViewController = storyboard?.instantiateViewController(
            identifier: "DetailsViewController",
            creator: { coder in
                DetailsViewController(mantra: mantra, mode: .edit, position: self.mantraArray.count, coder: coder)
        }) else { return }
        navigationController?.pushViewController(detailsViewController, animated: true)
    }
    
    @objc func doneButtonPressed() {
        self.setEditing(false, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
    }
    
    @objc func editButtonPressed() {
        self.setEditing(true, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
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
