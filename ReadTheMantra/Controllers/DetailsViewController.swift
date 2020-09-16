//
//  DetailsViewController.swift
//  ReadTheMantra
//
//  Created by Александр Воробьев on 02.08.2020.
//  Copyright © 2020 Александр Воробьев. All rights reserved.
//

import UIKit
// import PhotosUI

protocol DetailsViewControllerDelegate: class {
    func updateView()
}

class DetailsViewController: UIViewController {
    
    private var mantra: Mantra
    private var mode: DetailsMode
    private var position: Int
    private var mantraImageData: Data?
    private var mantraImageForTableViewData: Data?
    private weak var delegate: DetailsViewControllerDelegate?
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet private weak var setPhotoButton: UIButton!
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var mantraTextTextView: UITextView!
    @IBOutlet private weak var detailsTextView: UITextView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mantraTextLabel: UILabel!
    @IBOutlet weak var detailsTextLabel: UILabel!
    
    private var mantraTextPlaceholderLabel : UILabel!
    private var detailsPlaceholderLabel : UILabel!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init?(mantra: Mantra, mode: DetailsMode, position: Int, delegate: DetailsViewControllerDelegate, coder: NSCoder) {
        self.mantra = mantra
        self.position = position
        self.mode = mode
        self.delegate = delegate
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        hideKeyboardWhenTappedAround()
        
        titleLabel.text = NSLocalizedString("Title", comment: "Mantra title label")
        mantraTextLabel.text = NSLocalizedString("Mantra text", comment: "Mantra text label")
        detailsTextLabel.text = NSLocalizedString("Description", comment: "Mantra description label")
        titleTextField.placeholder = NSLocalizedString("Enter mantra title", comment: "Mantra title placeholder")
        setMantraTextPlaceholder()
        setDetailsPlaceholder()
        
        mantraImageData = mantra.image ?? nil
        mantraImageForTableViewData = mantra.image ?? nil
        
        setupUI()
        
        switch mode {
        case .add:
            setAddMode()
        case .edit:
            setEditMode()
        case .view:
            setViewMode()
        }
        
        navigationController?.presentationController?.delegate = self
        mantraTextTextView.delegate = self
        detailsTextView.delegate = self
    }
    
    private func setupUI() {
        if let imageData = mantraImageData {
            let image = UIImage(data: imageData)
            setPhotoButton.setImage(image, for: .normal)
        } else {
            let image = UIImage(named: K.defaultImage)
            setPhotoButton.setImage(image, for: .normal)
        }
        
        titleTextField.text = mantra.title
        mantraTextTextView.text = mantra.text
        detailsTextView.text = mantra.details
    }
    
    private func setAddMode() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Add", comment: "Button on MantraTableViewController"), style: .done, target: self, action: #selector(addButtonPressed))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed))
        setPhotoButton.isUserInteractionEnabled = true
        titleTextField.isUserInteractionEnabled = true
        mantraTextTextView.isEditable = true
        detailsTextView.isEditable = true
        titleTextField.becomeFirstResponder()
        mantraTextPlaceholderLabel.isHidden = !mantraTextTextView.text.isEmpty
        detailsPlaceholderLabel.isHidden = !detailsTextView.text.isEmpty
    }
    
    private func setEditMode() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonPressed))
        setPhotoButton.isUserInteractionEnabled = true
        titleTextField.isUserInteractionEnabled = true
        mantraTextTextView.isEditable = true
        detailsTextView.isEditable = true
        titleTextField.becomeFirstResponder()
        mantraTextPlaceholderLabel.isHidden = !mantraTextTextView.text.isEmpty
        detailsPlaceholderLabel.isHidden = !detailsTextView.text.isEmpty
    }
    
    private func setViewMode() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonPressed))
        setPhotoButton.isUserInteractionEnabled = false
        titleTextField.isUserInteractionEnabled = false
        mantraTextTextView.isEditable = false
        detailsTextView.isEditable = false
        titleTextField.resignFirstResponder()
        mantraTextTextView.resignFirstResponder()
        detailsTextView.resignFirstResponder()
        mantraTextPlaceholderLabel.isHidden = true
        detailsPlaceholderLabel.isHidden = true
    }
    
    //MARK: - Buttons Methods
    
    @objc private func addButtonPressed() {
        if let title = titleTextField.text, let text = mantraTextTextView.text, let details = detailsTextView.text, title != "" {
            processMantra(title: title, text: text, details: details)
            saveMantras()
            context.reset()
            delegate?.updateView()
            dismiss(animated: true, completion: nil)
        } else {
            incorrectTitleAlert()
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
        if let title = titleTextField.text, let text = mantraTextTextView.text, let details = detailsTextView.text, title != "" {
            processMantra(title: title, text: text, details: details)
            saveMantras()
            delegate?.updateView()
            setViewMode()
        } else {
            incorrectTitleAlert()
        }
    }
    
    @objc private func closeButtonPressed() {
        delegate?.updateView()
        dismiss(animated: true, completion: nil)
    }
    
    private func processMantra(title: String, text: String, details: String) {
        mantra.title = title
        mantra.text = text
        mantra.details = details
        mantra.position = Int32(position)
        mantra.image = mantraImageData ?? nil
        mantra.imageForTableView = mantraImageForTableViewData ?? nil
    }
    
    private func incorrectTitleAlert() {
        let alert = UIAlertController(title: NSLocalizedString("Please add a valid title", comment: "Alert Title on DetailsViewController"),
                                      message: nil,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
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
                                                self?.setPhotoButton.setImage(UIImage(named: K.defaultImage), for: .normal)
                                                self?.mantraImageData = nil
                                                self?.mantraImageForTableViewData = nil
        }
    
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(photoLibraryAction)
        alert.addAction(defaultPhotoAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func showImagePicker() {
//        if #available(iOS 14.0, *) {
//              var configuration = PHPickerConfiguration()
//              configuration.filter = .images
//              let picker = PHPickerViewController(configuration: configuration)
//              picker.delegate = self
//              present(picker, animated: true, completion: nil)
//        } else {
            let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.sourceType = .photoLibrary
            picker.delegate = self
            present(picker, animated: true)
//        }
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

    private func processImage (image: UIImage) {
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

//extension ViewController: PHPickerViewControllerDelegate {
//    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//        dismiss(animated: true, completion: nil)
//        guard !results.isEmpty else { return }
//        if provider.canLoadObject(ofClass: UIImage.self) {
//            provider.loadObject(ofClass: UIImage.self) { (image, error) in
//                DispatchQueue.main.async {
//                    if let image = image as? UIImage {
//                        processImage(image: image)
//                    }
//                }
//            }
//        }
//    }
//}

//MARK: - UIAdaptivePresentationController Delegate (Handling dismisson of modal view)

extension DetailsViewController: UIAdaptivePresentationControllerDelegate {

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        switch delegate {
        case is MantraTableViewController:
            context.reset()
            delegate?.updateView()
        case is ReadsCountViewController:
            delegate?.updateView()
        default:
            return
        }
    }
}

