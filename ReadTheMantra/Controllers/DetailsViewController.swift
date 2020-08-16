//
//  DetailsViewController.swift
//  ReadTheMantra
//
//  Created by Александр Воробьев on 02.08.2020.
//  Copyright © 2020 Александр Воробьев. All rights reserved.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController {
    
    private var mantra: Mantra
    private var mode: DetailsMode
    private var position: Int
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var mantraTextTextView: UITextView!
    @IBOutlet weak var detailsTextView: UITextView!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init?(mantra: Mantra, mode: DetailsMode, position: Int, coder: NSCoder) {
        self.mantra = mantra
        self.position = position
        self.mode = mode
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        hideKeyboardWhenTappedAround()
        
        setupUI()
    }
    
    //MARK: - Action Methods
    
    @objc func doneButtonPressed() {
        if let title = titleTextField.text, let text = mantraTextTextView.text, let details = detailsTextView.text, title != "" {
            processMantra(title: title, text: text, details: details)
            saveMantras()
            titleTextField.resignFirstResponder()
            mantraTextTextView.resignFirstResponder()
            detailsTextView.resignFirstResponder()
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
        } else {
            incorrectTitleAlert()
        }
        titleTextField.isUserInteractionEnabled = false
        mantraTextTextView.isEditable = false
        detailsTextView.isEditable = false
    }
    
    @objc func editButtonPressed() {
        titleTextField.isUserInteractionEnabled = true
        mantraTextTextView.isEditable = true
        detailsTextView.isEditable = true
        titleTextField.becomeFirstResponder()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
    }
    
    //MARK: - Supportive Methods
    
    private func processMantra(title: String, text: String, details: String) {
        mantra.title = title
        mantra.text = text
        mantra.details = details
        if mode == .add {
            mantra.position = Int32(position)
        }
    }
    
    private func incorrectTitleAlert() {
        let alert = UIAlertController(title: NSLocalizedString("Please add a valid title", comment: "Alert Title on DetailsViewController"),
                                      message: "",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func setupUI() {
        image.image = UIImage(named: "default")
        image.makeRounded()
        
        mantraTextTextView.layer.borderWidth = 0.4
        mantraTextTextView.layer.borderColor = UIColor.systemGray.cgColor
        detailsTextView.layer.borderWidth = 0.4
        detailsTextView.layer.borderColor = UIColor.systemGray.cgColor
        
        switch mode {
        case .add:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
            titleTextField.becomeFirstResponder()
        case .view:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
            titleTextField.isUserInteractionEnabled = false
            mantraTextTextView.isEditable = false
            detailsTextView.isEditable = false
        }
        
        titleTextField.text = mantra.title
        mantraTextTextView.text = mantra.text
        detailsTextView.text = mantra.details
    }
    
    //MARK: - Model Manipulation
    
    private func saveMantras() {
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
    }
}
