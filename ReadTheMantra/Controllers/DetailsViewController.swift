//
//  DetailsViewController.swift
//  ReadTheMantra
//
//  Created by Александр Воробьев on 02.08.2020.
//  Copyright © 2020 Александр Воробьев. All rights reserved.
//

import UIKit
import PhotosUI

protocol DetailsViewControllerDelegate: class {
    func updateView()
}

class DetailsViewController: UIViewController {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var mantra: Mantra
    private var mode: DetailsMode
    private var position: Int
    private var mantraTitles: [String]?
    private var mantraImageData: Data?
    private var mantraImageForTableViewData: Data?
    private weak var delegate: DetailsViewControllerDelegate?
    
    @IBOutlet private weak var setPhotoButton: UIButton!
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var mantraTextTextView: UITextView!
    @IBOutlet private weak var detailsTextView: UITextView!
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var mantraTextLabel: UILabel!
    @IBOutlet private weak var detailsTextLabel: UILabel!
    
    private var mantraTextPlaceholderLabel : UILabel!
    private var detailsPlaceholderLabel : UILabel!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init?(mantra: Mantra, mode: DetailsMode, position: Int, mantraTitles: [String]? = nil, delegate: DetailsViewControllerDelegate? = nil, coder: NSCoder) {
        self.mantra = mantra
        self.mode = mode
        self.position = position
        self.mantraTitles = mantraTitles
        self.delegate = delegate
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        navigationItem.largeTitleDisplayMode = .never
        
        mantraImageData = mantra.image ?? nil
        mantraImageForTableViewData = mantra.image ?? nil
        
        setupUI()
        
        navigationController?.presentationController?.delegate = self
        titleTextField.delegate = self
        mantraTextTextView.delegate = self
        detailsTextView.delegate = self
    }
    
    private func setupUI() {
        
        titleLabel.text = NSLocalizedString("Title", comment: "Mantra title label")
        mantraTextLabel.text = NSLocalizedString("Mantra text", comment: "Mantra text label")
        detailsTextLabel.text = NSLocalizedString("Description", comment: "Mantra description label")
        titleTextField.placeholder = NSLocalizedString("Enter mantra title", comment: "Mantra title placeholder")
        titleTextField.font = UIFont.preferredFont(for: .title2, weight: .medium)
        titleTextField.adjustsFontForContentSizeCategory = true
        setMantraTextPlaceholder()
        setDetailsPlaceholder()
        
        let mantraImage = (mantraImageData != nil) ? UIImage(data: mantraImageData!) : UIImage(named: K.defaultImage)
        setPhotoButton.setImage(mantraImage, for: .normal)
        setPhotoButton.addPencilMark(color: .label)
        setPhotoButton.viewWithTag(1)?.alpha = 0
        
        titleTextField.text = mantra.title
        mantraTextTextView.text = mantra.text
        detailsTextView.text = mantra.details
        
        switch mode {
        case .add:
            setAddMode()
        case .edit:
            setEditMode()
        case .view:
            setViewMode()
        }
    }
    
    private func setAddMode() {
        navigationItem.title = NSLocalizedString("New Mantra", comment: "Add new mantra bar title")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Add", comment: "Button on MantraTableViewController"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(addButtonPressed))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed))
        navigationItem.rightBarButtonItem?.isEnabled = false
        setPhotoButton.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.2) {
            self.setPhotoButton.alpha = 0.7
            self.setPhotoButton.viewWithTag(1)?.alpha = 0.7
        }
        titleTextField.isUserInteractionEnabled = true
        mantraTextTextView.isEditable = true
        detailsTextView.isEditable = true
        titleTextField.becomeFirstResponder()
        mantraTextPlaceholderLabel.isHidden = !mantraTextTextView.text.isEmpty
        detailsPlaceholderLabel.isHidden = !detailsTextView.text.isEmpty
    }
    
    private func setEditMode() {
        navigationItem.title = NSLocalizedString("Information", comment: "Information bar title")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonPressed))
        setPhotoButton.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.2) {
            self.setPhotoButton.alpha = 0.7
            self.setPhotoButton.viewWithTag(1)?.alpha = 0.7
        }
        titleTextField.isUserInteractionEnabled = true
        mantraTextTextView.isEditable = true
        detailsTextView.isEditable = true
        titleTextField.becomeFirstResponder()
        mantraTextPlaceholderLabel.isHidden = !mantraTextTextView.text.isEmpty
        detailsPlaceholderLabel.isHidden = !detailsTextView.text.isEmpty
    }
    
    private func setViewMode() {
        navigationItem.title = NSLocalizedString("Information", comment: "Information bar title")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonPressed))
        setPhotoButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.2) {
            self.setPhotoButton.alpha = 1
            self.setPhotoButton.viewWithTag(1)?.alpha = 0
        }
        titleTextField.isUserInteractionEnabled = false
        mantraTextTextView.isEditable = false
        detailsTextView.isEditable = false
        titleTextField.resignFirstResponder()
        mantraTextTextView.resignFirstResponder()
        detailsTextView.resignFirstResponder()
        mantraTextPlaceholderLabel.isHidden = true
        detailsPlaceholderLabel.isHidden = true
    }
    
    //MARK: - Navigation Bar Buttons Methods
    
    @objc private func addButtonPressed() {
        guard let title = titleTextField.text else { return }
        if isMantraDuplicating(for: title) {
            showDuplicatingAlert(for: title)
        } else {
            handleAddNewMantra(for: title)
        }
    }
    
    @objc private func cancelButtonPressed() {
        context.reset()
        delegate?.updateView()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func editButtonPressed() {
        setEditMode()
    }
    
    @objc private func doneButtonPressed() {
        guard let title = titleTextField.text else { return }
        processMantra(title: title)
        saveMantras()
        delegate?.updateView()
        setViewMode()
    }
    
    @objc private func closeButtonPressed() {
        delegate?.updateView()
        dismiss(animated: true, completion: nil)
    }
    
    private func isMantraDuplicating(for title: String) -> Bool {
        guard let mantraTitles = mantraTitles else { return false }
        return mantraTitles.contains(title)
    }
    
    private func showDuplicatingAlert(for title: String) {
        let alert = UIAlertController(title: nil,
                                      message: NSLocalizedString("It's already in your mantra list. Add another one?", comment: "Alert Message for Duplication"),
                                      preferredStyle: .alert)
        let addAction = UIAlertAction(title: NSLocalizedString("Add", comment: "Alert Button on MantraTableViewController"),
                                      style: .default) { [weak self] (action) in
            self?.handleAddNewMantra(for: title)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert Button on MantraTableViewController"),
                                         style: .default, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func handleAddNewMantra(for title: String) {
        processMantra(title: title)
        saveMantras()
        context.reset()
        delegate?.updateView()
        dismiss(animated: true, completion: nil)
    }
    
    private func processMantra(title: String) {
        mantra.title = title
        mantra.text = mantraTextTextView.text
        mantra.details = detailsTextView.text
        mantra.position = Int32(position)
        mantra.image = mantraImageData ?? nil
        mantra.imageForTableView = mantraImageForTableViewData ?? nil
    }
    
    //MARK: - SetPhoto Action
    
    @IBAction func setPhotoButtonPressed(_ sender: UIButton) {
    
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let photoLibraryAction = UIAlertAction(title: NSLocalizedString("Photo Library", comment: "Alert Title on DetailsViewController"),
                                               style: .default) { [weak self] (action) in
                                                self?.showImagePicker()
        }
     
        let defaultPhotoAction = UIAlertAction(title: NSLocalizedString("Standard Image", comment: "Alert Title on DetailsViewController"),
                                               style: .default) { [weak self] (action) in
                                                self?.setDefaultImage()
        }
    
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Alert Button on MantraTableViewController"),
                                         style: .cancel,
                                         handler: nil)
        alert.addAction(photoLibraryAction)
        alert.addAction(defaultPhotoAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func showImagePicker() {
        if #available(iOS 14, *) {
              var configuration = PHPickerConfiguration()
              configuration.filter = .images
              let picker = PHPickerViewController(configuration: configuration)
              picker.delegate = self
              present(picker, animated: true, completion: nil)
        } else {
            let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.sourceType = .photoLibrary
            picker.delegate = self
            present(picker, animated: true)
        }
    }
    
    private func setDefaultImage() {
        setPhotoButton.setImage(UIImage(named: K.defaultImage), for: .normal)
        mantraImageData = nil
        mantraImageForTableViewData = nil
    }
    
    //MARK: - TextViews Placeholders
    
    private func setMantraTextPlaceholder() {
        mantraTextPlaceholderLabel = UILabel()
        mantraTextPlaceholderLabel.text = NSLocalizedString("Enter mantra text", comment: "Mantra text placeholder")
        if let fontPointSize = detailsTextView.font?.pointSize {
            mantraTextPlaceholderLabel.font = .systemFont(ofSize: fontPointSize)
            mantraTextPlaceholderLabel.sizeToFit()
            mantraTextTextView.addSubview(mantraTextPlaceholderLabel)
            mantraTextPlaceholderLabel.frame.origin = CGPoint(x: 5, y: fontPointSize / 3)
            mantraTextPlaceholderLabel.textColor = .placeholderText
            mantraTextPlaceholderLabel.isHidden = !mantraTextTextView.text.isEmpty
        }
    }
    
    private func setDetailsPlaceholder() {
        detailsPlaceholderLabel = UILabel()
        detailsPlaceholderLabel.text = NSLocalizedString("Enter mantra description", comment: "Mantra description placeholder")
        if let fontPointSize = detailsTextView.font?.pointSize {
            detailsPlaceholderLabel.font = .systemFont(ofSize: fontPointSize)
            detailsPlaceholderLabel.sizeToFit()
            detailsTextView.addSubview(detailsPlaceholderLabel)
            detailsPlaceholderLabel.frame.origin = CGPoint(x: 5, y: fontPointSize / 3)
            detailsPlaceholderLabel.textColor = .placeholderText
            detailsPlaceholderLabel.isHidden = !detailsTextView.text.isEmpty
        }
    }

    //MARK: - Model Manipulation
    
    private func saveMantras() {
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
    }

    //MARK: - Process Image

    private func processImage(image: UIImage) {
        let circledImage = image.circle()
        let resizedCircledImage = circledImage?.resize(to: CGSize(width: 320, height: 320))
        let resizedCircledImageForTableView = circledImage?.resize(to: CGSize(width: 160, height: 160))
        
        if let imageData = resizedCircledImage?.pngData() {
            mantraImageData = imageData
            setPhotoButton.setImage(resizedCircledImage, for: .normal)
        }
        if let imageData = resizedCircledImageForTableView?.pngData() {
            mantraImageForTableViewData = imageData
        }
    }
}

//MARK: - TextField Delegate (Validating Mantra Title)

extension DetailsViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        navigationItem.rightBarButtonItem?.isEnabled = (textField.text != "")
    }
}

//MARK: - TextView Delegate (Handling TextViews Placeholders)

extension DetailsViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        mantraTextPlaceholderLabel.isHidden = !mantraTextTextView.text.isEmpty
        detailsPlaceholderLabel.isHidden = !detailsTextView.text.isEmpty
    }
}

//MARK: - ImagePickerController Delegate

extension DetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage else { return }
        
        processImage(image: image)
    }
}

//MARK: - PHPickerViewController Delegate

extension DetailsViewController: PHPickerViewControllerDelegate {
    
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        
        guard !results.isEmpty else { return }
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self.processImage(image: image)
                    }
                }
            })
        }
    }
}

//MARK: - UIAdaptivePresentationController Delegate (Handling dismisson of modal view)

extension DetailsViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if delegate is MantraTableViewController {
            context.reset()
        }
        delegate?.updateView()
    }
}
