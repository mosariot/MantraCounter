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
    private var mantraImageData: Data?
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var setPhotoButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var mantraTextTextView: UITextView!
    @IBOutlet weak var detailsTextView: UITextView!
    
    var mantraTextPlaceholderLabel : UILabel!
    var detailsPlaceholderLabel : UILabel!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init?(mantra: Mantra, mode: DetailsMode, position: Int, coder: NSCoder) {
        self.mantra = mantra
        self.position = position
        self.mode = mode
        if let imageData = mantra.image {
            mantraImageData = imageData
        }
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        hideKeyboardWhenTappedAround()
        
        updateUI()
        
        mantraTextTextView.delegate = self
        detailsTextView.delegate = self
        setMantraTextPlaceholder()
        setDetailsPlaceholder()
    }
    
    //MARK: - Action Methods
    
    @objc func editButtonPressed() {
        setPhotoButton.isUserInteractionEnabled = true
        titleTextField.isUserInteractionEnabled = true
        mantraTextTextView.isEditable = true
        detailsTextView.isEditable = true
        titleTextField.becomeFirstResponder()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
    }
    
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
        setPhotoButton.isUserInteractionEnabled = false
        titleTextField.isUserInteractionEnabled = false
        mantraTextTextView.isEditable = false
        detailsTextView.isEditable = false
    }
    
    @IBAction func setPhotoButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let photoLibraryAction = UIAlertAction(title: NSLocalizedString("Photo Library", comment: "Alert Title on DetailsViewController"),
                                               style: .default) { [weak self] (action) in
                                                self?.callImagePicker()
        }
        let defaultPhotoAction = UIAlertAction(title: NSLocalizedString("Default Photo", comment: "Alert Title on DetailsViewController"),
                                               style: .default) { [weak self] (action) in
                                                self?.setPhotoButton.setImage(UIImage(named: "default"), for: .normal)
                                                self?.mantraImageData = nil
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(photoLibraryAction)
        alert.addAction(defaultPhotoAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Supportive Methods
    
    private func processMantra(title: String, text: String, details: String) {
        mantra.title = title
        mantra.text = text
        mantra.details = details
        if let imageData = mantraImageData {
            mantra.image = imageData
        } else {
            mantra.image = nil
        }
        if mode == .addOrEdit {
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
    
    func callImagePicker() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func updateUI() {
        if let imageData = mantraImageData {
            setPhotoButton.setImage(UIImage(data: imageData), for: .normal)
        } else {
            setPhotoButton.setImage(UIImage(named: "default"), for: .normal)
        }
        setPhotoButton.imageView?.makeRounded()
        
        switch mode {
        case .addOrEdit:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
            titleTextField.becomeFirstResponder()
        case .view:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
            setPhotoButton.isUserInteractionEnabled = false
            titleTextField.isUserInteractionEnabled = false
            mantraTextTextView.isEditable = false
            detailsTextView.isEditable = false
        }
        
        titleTextField.text = mantra.title
        mantraTextTextView.text = mantra.text
        detailsTextView.text = mantra.details
    }
    
    private func setMantraTextPlaceholder() {
        mantraTextPlaceholderLabel = UILabel()
        mantraTextPlaceholderLabel.text = NSLocalizedString("Enter mantra text", comment: "Mantra text placeholder")
        mantraTextPlaceholderLabel.font = .systemFont(ofSize: (mantraTextTextView.font?.pointSize)!)
        mantraTextPlaceholderLabel.sizeToFit()
        mantraTextTextView.addSubview(mantraTextPlaceholderLabel)
        mantraTextPlaceholderLabel.frame.origin = CGPoint(x: 5, y: (mantraTextTextView.font?.pointSize)! / 3)
        mantraTextPlaceholderLabel.textColor = .systemGray2
        mantraTextPlaceholderLabel.isHidden = !mantraTextTextView.text.isEmpty
    }
    
    private func setDetailsPlaceholder() {
        detailsPlaceholderLabel = UILabel()
        detailsPlaceholderLabel.text = NSLocalizedString("Enter mantra description", comment: "Mantra description placeholder")
        detailsPlaceholderLabel.font = .systemFont(ofSize: (detailsTextView.font?.pointSize)!)
        detailsPlaceholderLabel.sizeToFit()
        detailsTextView.addSubview(detailsPlaceholderLabel)
        detailsPlaceholderLabel.frame.origin = CGPoint(x: 5, y: (detailsTextView.font?.pointSize)! / 3)
        detailsPlaceholderLabel.textColor = .systemGray2
        detailsPlaceholderLabel.isHidden = !detailsTextView.text.isEmpty
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

//MARK: - UITextViewDelegate

extension DetailsViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        mantraTextPlaceholderLabel.isHidden = !mantraTextTextView.text.isEmpty
        detailsPlaceholderLabel.isHidden = !detailsTextView.text.isEmpty
    }
}

//MARK: - ImagePickerController Delegate

extension DetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else  { return }
        
        if let imageData = image.pngData() {
            mantraImageData = imageData
            mode = .addOrEdit
            updateUI()
        }
        dismiss(animated: true)
    }
}
