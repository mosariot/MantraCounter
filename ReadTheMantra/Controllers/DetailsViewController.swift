//
//  DetailsViewController.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 02.08.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit
import PhotosUI
import SafariServices

final class DetailsViewController: UIViewController {
    
    //MARK: - Properties
    
    private lazy var dataProvider = MantraProvider()
    
    private let pasteboard = UIPasteboard.general
    private let addHapticGenerator = UINotificationFeedbackGenerator()
    
    private var mantra: Mantra
    private var mantraTitles: [String]?
    private var mode: DetailsMode {
        didSet { setMode () }
    }
    private var mantraImageData: Data?
    private var mantraImageForTableViewData: Data?
    private weak var callerController: UIViewController?
    
    private var detailsView: DetailsView! {
        guard isViewLoaded else { return nil }
        return (view as! DetailsView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Init
    
    init?(mantra: Mantra,
          mode: DetailsMode,
          mantraTitles: [String]? = nil,
          callerController: UIViewController? = nil,
          coder: NSCoder) {
        self.mantra = mantra
        self.mantraTitles = mantraTitles
        self.mode = mode
        self.callerController = callerController
        
        super.init(coder: coder)
    }
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        view.fixInputAssistant()
        
        navigationItem.largeTitleDisplayMode = .never
        
        mantraImageData = mantra.image ?? nil
        mantraImageForTableViewData = mantra.imageForTableView ?? nil
        
        detailsView.titleTextField.delegate = self
        detailsView.mantraTextTextView.delegate = self
        detailsView.detailsTextView.delegate = self
        
        addHapticGenerator.prepare()
        
        setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        addGesturesRecongizers()
    }
    
    private func setupData() {
        detailsView.titleTextField.text = mantra.title
        detailsView.mantraTextTextView.text = mantra.text
        detailsView.detailsTextView.text = mantra.details
        
        let mantraImage = (mantra.image != nil) ? UIImage(data: mantra.image!) : UIImage(named: Constants.defaultImage)
        let downsampledMantraImage = mantraImage?.resize(to: detailsView.setPhotoButton.bounds.size)
        detailsView.setPhotoButton.setImage(downsampledMantraImage, for: .normal)
    }
    
    private func setupUI() {
        
        detailsView.titleStackView.customize(backgroundColor: .secondarySystemGroupedBackground, radiusSize: 15)
        detailsView.mantraTextStackView.customize(backgroundColor: .secondarySystemGroupedBackground, radiusSize: 15)
        detailsView.detailsStackView.customize(backgroundColor: .secondarySystemGroupedBackground, radiusSize: 15)
        
        detailsView.titleLabel.text = NSLocalizedString("TITLE", comment: "Mantra title label")
        detailsView.mantraTextLabel.text = NSLocalizedString("MANTRA TEXT", comment: "Mantra text label")
        detailsView.detailsTextLabel.text = NSLocalizedString("DESCRIPTION", comment: "Mantra description label")
        detailsView.titleTextField.placeholder = NSLocalizedString("Enter mantra title", comment: "Mantra title placeholder")
        detailsView.titleTextField.font = UIFont.preferredFont(for: .title2, weight: .medium)
        detailsView.titleTextField.adjustsFontForContentSizeCategory = true
        detailsView.mantraTextTextView.placeHolderText = NSLocalizedString("Enter mantra text", comment: "Mantra text placeholder")
        detailsView.detailsTextView.placeHolderText = NSLocalizedString("Enter mantra description", comment: "Mantra description placeholder")
        
        detailsView.setPhotoButton.showsMenuAsPrimaryAction = true
        let photoLibraryAction = UIAction(
            title: NSLocalizedString("Photo Library", comment: "Menu Item on DetailsViewController"),
            image: UIImage(systemName: "photo.on.rectangle.angled")) { [weak self] _ in
            guard let self = self else { return }
            self.showImagePicker()
        }
        let standardImageAction = UIAction(
            title: NSLocalizedString("Standard Image", comment: "Menu Item on DetailsViewController"),
            image: UIImage(systemName: "photo")) { [weak self] _ in
            guard let self = self else { return }
            self.setDefaultImage()
        }
        let searchAction = UIAction(
            title: NSLocalizedString("Search on the Internet", comment: "Menu Item on DetailsViewController"),
            image: UIImage(systemName: "globe")) { [weak self] _ in
            guard let self = self else { return }
            self.searchOnTheInternet()
        }
        let photoMenu = UIMenu(children: [photoLibraryAction, standardImageAction, searchAction])
        detailsView.setPhotoButton.menu = photoMenu
        
        setMode()
    }
    
    private func addGesturesRecongizers() {
        
        let titleGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showTitleKeyboard))
        detailsView.titleStackView.addGestureRecognizer(titleGestureRecognizer)
        
        let textGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showTextKeyboard))
        detailsView.mantraTextStackView.addGestureRecognizer(textGestureRecognizer)
        
        let descriptionGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showDescriptionKeyboard))
        detailsView.detailsStackView.addGestureRecognizer(descriptionGestureRecognizer)
        
    }
    
    @objc private func showTitleKeyboard(_ recognizer: UIGestureRecognizer) {
        if mode != .view && !detailsView.titleTextField.isFirstResponder {
            detailsView.titleTextField.becomeFirstResponder()
            let newPosition = detailsView.titleTextField.endOfDocument
            detailsView.titleTextField.selectedTextRange = detailsView.titleTextField.textRange(from: newPosition, to: newPosition)
        }
    }
    
    @objc private func showTextKeyboard(_ recognizer: UIGestureRecognizer) {
        if mode != .view && !detailsView.mantraTextTextView.isFirstResponder {
            detailsView.mantraTextTextView.becomeFirstResponder()
            let newPosition = detailsView.mantraTextTextView.endOfDocument
            detailsView.mantraTextTextView.selectedTextRange = detailsView.mantraTextTextView.textRange(from: newPosition, to: newPosition)
        }
    }
    
    @objc private func showDescriptionKeyboard(_ recognizer: UIGestureRecognizer) {
        if mode != .view && !detailsView.detailsTextView.isFirstResponder {
            detailsView.detailsTextView.becomeFirstResponder()
            let newPosition = detailsView.detailsTextView.endOfDocument
            detailsView.detailsTextView.selectedTextRange = detailsView.detailsTextView.textRange(from: newPosition, to: newPosition)
        }
    }
    
    
    private func setMode() {
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
        title = NSLocalizedString("New Mantra", comment: "Add new mantra bar title")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Add", comment: "Button on MantraTableViewController"),
            primaryAction: UIAction(handler: { [weak self] _ in
                guard let self = self else { return }
                self.addButtonPressed()
            }))
        navigationItem.rightBarButtonItem?.style = .done
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .cancel,
            primaryAction: UIAction(handler: { [weak self] _ in
                guard let self = self else { return }
                self.cancelButtonPressed()
            }))
        navigationItem.rightBarButtonItem?.isEnabled = (detailsView.titleTextField.text != "")
        detailsView.setPhotoButton.setEditMode()
        detailsView.titleTextField.isUserInteractionEnabled = true
        detailsView.mantraTextTextView.isUserInteractionEnabled = true
        detailsView.mantraTextTextView.isEditable = true
        detailsView.detailsTextView.isUserInteractionEnabled = true
        detailsView.detailsTextView.isEditable = true
        detailsView.titleTextField.becomeFirstResponder()
        detailsView.mantraTextTextView.placeHolder.isHidden = !detailsView.mantraTextTextView.text.isEmpty
        detailsView.detailsTextView.placeHolder.isHidden = !detailsView.detailsTextView.text.isEmpty
    }
    
    private func setEditMode() {
        title = NSLocalizedString("Information", comment: "Information bar title")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .done,
            primaryAction: UIAction(handler: { [weak self] _ in
                guard let self = self else { return }
                self.doneButtonPressed()
            }))
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .close,
            primaryAction: UIAction(handler: { [weak self] _ in
                guard let self = self else { return }
                self.closeButtonPressed()
            }))
        detailsView.setPhotoButton.setEditMode()
        detailsView.titleTextField.isUserInteractionEnabled = true
        detailsView.mantraTextTextView.isUserInteractionEnabled = true
        detailsView.mantraTextTextView.isEditable = true
        detailsView.detailsTextView.isUserInteractionEnabled = true
        detailsView.detailsTextView.isEditable = true
        detailsView.titleTextField.becomeFirstResponder()
        detailsView.mantraTextTextView.placeHolder.isHidden = !detailsView.mantraTextTextView.text.isEmpty
        detailsView.detailsTextView.placeHolder.isHidden = !detailsView.detailsTextView.text.isEmpty
    }
    
    private func setViewMode() {
        navigationItem.title = NSLocalizedString("Information", comment: "Information bar title")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .edit,
            primaryAction: UIAction(handler: { [weak self] _ in
                guard let self = self else { return }
                self.editButtonPressed()
            }))
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .close,
            primaryAction: UIAction(handler: { [weak self] _ in
                guard let self = self else { return }
                self.closeButtonPressed()
            }))
        detailsView.setPhotoButton.setViewMode()
        detailsView.titleTextField.isUserInteractionEnabled = false
        detailsView.mantraTextTextView.isUserInteractionEnabled = false
        detailsView.mantraTextTextView.isEditable = false
        detailsView.detailsTextView.isUserInteractionEnabled = false
        detailsView.detailsTextView.isEditable = false
        detailsView.titleTextField.resignFirstResponder()
        detailsView.mantraTextTextView.resignFirstResponder()
        detailsView.detailsTextView.resignFirstResponder()
        detailsView.mantraTextTextView.placeHolder.isHidden = true
        detailsView.detailsTextView.placeHolder.isHidden = true
    }
}

//MARK: - Navigation Bar Buttons Methods

extension DetailsViewController {
    
    private func addButtonPressed() {
        guard let title = detailsView.titleTextField.text else { return }
        if isMantraDuplicating(for: title) {
            showDuplicatingAlert(for: title)
        } else {
            handleAddNewMantra(for: title)
        }
    }
    
    private func cancelButtonPressed() {
        guard let title = detailsView.titleTextField.text else { return }
        if detailsView.titleTextField.text?.trimmingCharacters(in: .whitespaces) == ""
            && detailsView.mantraTextTextView.text == ""
            && detailsView.detailsTextView.text == ""
            && mantraImageData == nil {
            self.dataProvider.deleteMantra(mantra)
            self.dismiss(animated: true, completion: nil)
            return
        }
        let alert = UIAlertController.cancelOrCloseMantraAlert(
            idiom: traitCollection.userInterfaceIdiom,
            saveMantraHandler: { [weak self] in
                guard let self = self else { return }
                self.handleAddNewMantra(for: title)
            }, dontSaveActionHandler: { [weak self] in
                guard let self = self else { return }
                self.dataProvider.deleteMantra(self.mantra)
                self.dismiss(animated: true, completion: nil)
            })
        present(alert, animated: true, completion: nil)
        
    }
    
    private func editButtonPressed() {
        mode = .edit
    }
    
    private func doneButtonPressed() {
        guard let title = detailsView.titleTextField.text else { return }
        dataProvider.buildOrUpdateMantra(
            mantra: mantra,
            title: title,
            text: detailsView.mantraTextTextView.text,
            details: detailsView.detailsTextView.text,
            imageData: mantraImageData,
            imageForTableViewData: mantraImageForTableViewData)
        mode = .view
    }
    
    private func closeButtonPressed() {
        if detailsView.titleTextField.text != mantra.title
            || detailsView.mantraTextTextView.text != mantra.text ?? ""
            || detailsView.detailsTextView.text != mantra.details
            || mantraImageData != mantra.image {
            guard let title = detailsView.titleTextField.text else { return }
            let alert = UIAlertController.cancelOrCloseMantraAlert(
                idiom: traitCollection.userInterfaceIdiom,
                saveMantraHandler: { [weak self] in
                    guard let self = self else { return }
                    guard self.detailsView.titleTextField.text?.trimmingCharacters(in: .whitespaces) != "" else {
                        let alert = UIAlertController.addTitleAlert()
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    self.dataProvider.buildOrUpdateMantra(
                        mantra: self.mantra,
                        title: title,
                        text: self.detailsView.mantraTextTextView.text,
                        details: self.detailsView.detailsTextView.text,
                        imageData: self.mantraImageData,
                        imageForTableViewData: self.mantraImageForTableViewData)
                    self.dismiss(animated: true, completion: nil)
                }, dontSaveActionHandler: { [weak self] in
                    guard let self = self else { return }
                    self.dismiss(animated: true, completion: nil)
                })
            present(alert, animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func isMantraDuplicating(for title: String) -> Bool {
        guard let mantraTitles = mantraTitles else { return false }
        return mantraTitles.contains(title)
    }
    
    private func showDuplicatingAlert(for title: String) {
        let alert = UIAlertController.duplicatingAlert(idiom: traitCollection.userInterfaceIdiom) { [weak self] in
            guard let self = self else { return }
            self.handleAddNewMantra(for: title)
        } cancelActionHandler: { return }
        present(alert, animated: true, completion: nil)
    }
    
    private func handleAddNewMantra(for title: String) {
        guard detailsView.titleTextField.text?.trimmingCharacters(in: .whitespaces) != "" else {
            let alert = UIAlertController.addTitleAlert()
            present(alert, animated: true, completion: nil)
            return
        }
        
        dataProvider.buildOrUpdateMantra(
            mantra: mantra,
            title: title,
            text: detailsView.mantraTextTextView.text,
            details: detailsView.detailsTextView.text,
            imageData: mantraImageData,
            imageForTableViewData: mantraImageForTableViewData)
        
        addHapticGenerator.notificationOccurred(.success)
        
        let hudView = HudView.makeView(inView: navigationController?.view ?? view, animated: true)
        hudView.text = NSLocalizedString("Added", comment: "HUD title")
        afterDelay(0.8) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

//MARK: - SetPhoto Action

extension DetailsViewController {
    
    private func showImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    private func setDefaultImage() {
        detailsView.setPhotoButton.setImage(UIImage(named: Constants.defaultImage), for: .normal)
        addTransition()
        mantraImageData = nil
        mantraImageForTableViewData = nil
    }
    
    private func checkForFirstSearchOnTheInternet(handler: @escaping (UIAlertController) -> ()) {
        let defaults = UserDefaults.standard
        let isFirstSearchOnTheInternet = defaults.bool(forKey: "isFirstSearchOnTheInternet")
        if isFirstSearchOnTheInternet {
            let alert = UIAlertController.firstSearchOnTheInternetAlert()
            defaults.setValue(false, forKey: "isFirstSearchOnTheInternet")
            handler(alert)
        }
    }
    
    private func searchOnTheInternet() {
        guard let search = detailsView.titleTextField.text else { return }
        guard let urlString = "https://www.google.com/search?q=\(search)&tbm=isch"
                .addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else { return }
        guard let url = URL(string: urlString) else { return }
        let vc = SFSafariViewController(url: url)
        vc.delegate = self
        vc.modalPresentationStyle = .pageSheet
        vc.preferredControlTintColor = view.tintColor
        present(vc, animated: true) {
            self.checkForFirstSearchOnTheInternet { [weak vc] (alert) in
                guard let vc = vc else { return }
                vc.present(alert, animated: true, completion: nil)
            }
        }
    }
}

//MARK: - Process Image

extension DetailsViewController {
    
    private func processImage(image: UIImage) -> UIImage? {
        
        let circledImage = image.cropToCircle()
        let resizedCircledImage = circledImage?.resize(to: CGSize(width: 200, height: 200))
        let resizedCircledImageForTableView = circledImage?.resize(to: CGSize(width: Constants.rowHeight,
                                                                              height: Constants.rowHeight))
        if let imageData = resizedCircledImage?.pngData() {
            mantraImageData = imageData
        }
        if let imageData = resizedCircledImageForTableView?.pngData() {
            mantraImageForTableViewData = imageData
        }
        
        return resizedCircledImage
    }
}

//MARK: - TextField Delegate (Validating Mantra Title)

extension DetailsViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        navigationItem.rightBarButtonItem?.isEnabled = (textField.text?.trimmingCharacters(in: .whitespaces) != "")
    }
}

//MARK: - TextViewDelegate (Handling TextViews Placeholders)

extension DetailsViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        detailsView.mantraTextTextView.placeHolder.isHidden = !detailsView.mantraTextTextView.text.isEmpty
        detailsView.detailsTextView.placeHolder.isHidden = !detailsView.detailsTextView.text.isEmpty
    }
}

//MARK: - PHPickerViewControllerDelegate

extension DetailsViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        
        guard !results.isEmpty else { return }
        
        detailsView.setPhotoButton.setProcessMode()
        
        results.forEach { result in
            let provider = result.itemProvider
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self, completionHandler: { [weak self] (object, _) in
                    guard let self = self else { return }
                    if let image = object as? UIImage {
                        let resultImage = self.processImage(image: image)
                        DispatchQueue.main.async {
                            let downsampledImage = resultImage?.resize(to: self.detailsView.setPhotoButton.bounds.size)
                            self.detailsView.setPhotoButton.setImage(downsampledImage, for: .normal)
                            self.detailsView.setPhotoButton.setEditMode()
                            self.addTransition()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.detailsView.setPhotoButton.setEditMode()
                            self.showNoImageAlert()
                        }
                    }
                })
            }
        }
    }
    
    private func showNoImageAlert() {
        let alert = UIAlertController.noImageAlert { [weak self] in
            guard let self = self else { return }
            self.showImagePicker()
        }
        present(alert, animated: true, completion: nil)
    }
    
    private func addTransition() {
        let transition = CATransition()
        transition.type = .fade
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: .easeOut)
        view.layer.add(transition, forKey: nil)
    }
}

//MARK: - SFSafariViewControllerDelegate

extension DetailsViewController: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if pasteboard.hasImages {
            guard let image = pasteboard.image else { return }
            didSelectImageFromSafariController(image: image)
        } else if pasteboard.hasURLs {
            guard let url = pasteboard.url else { return }
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    didSelectImageFromSafariController(image: image)
                }
            }
        }
        pasteboard.items.removeAll()
    }
    
    private func didSelectImageFromSafariController(image: UIImage) {
        let resultImage = processImage(image: image)
        let downsampledImage = resultImage?.resize(to: detailsView.setPhotoButton.bounds.size)
        detailsView.setPhotoButton.setImage(downsampledImage, for: .normal)
    }
}
