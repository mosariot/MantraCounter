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

protocol DetailsViewControllerDelegate: class {
    func updateView()
}

final class DetailsViewController: UIViewController {
    
    //MARK: - Properties
    
    private lazy var coreDataManager = (UIApplication.shared.delegate as! AppDelegate).coreDataManager
    private lazy var context = (UIApplication.shared.delegate as! AppDelegate).coreDataManager.persistentContainer.viewContext
    
    private let pasteboard = UIPasteboard.general
    
    private var mantra: Mantra
    private var mantraTitles: [String]?
    private var mode: DetailsMode {
        didSet { setMode () }
    }
    private var mantraImageData: Data?
    private var mantraImageForTableViewData: Data?
    private weak var delegate: DetailsViewControllerDelegate?
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var titleStackView: UIStackView!
    @IBOutlet private weak var mantraTextStackView: UIStackView!
    @IBOutlet private weak var descriptionStackView: UIStackView!
    @IBOutlet private weak var setPhotoButton: SetPhotoButton!
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var mantraTextTextView: TextViewWithPlaceholder!
    @IBOutlet private weak var detailsTextView: TextViewWithPlaceholder!
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var mantraTextLabel: UILabel!
    @IBOutlet private weak var detailsTextLabel: UILabel!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Init
    
    init?(mantra: Mantra,
          mode: DetailsMode,
          mantraTitles: [String]? = nil,
          delegate: DetailsViewControllerDelegate?,
          coder: NSCoder) {
        self.mantra = mantra
        self.mantraTitles = mantraTitles
        self.mode = mode
        self.delegate = delegate
        
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
        
        navigationController?.presentationController?.delegate = self
        titleTextField.delegate = self
        mantraTextTextView.delegate = self
        detailsTextView.delegate = self
        
        setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupUI()
    }
    
    private func setupData() {
        titleTextField.text = mantra.title
        mantraTextTextView.text = mantra.text
        detailsTextView.text = mantra.details
        
        let mantraImage = (mantra.image != nil) ? UIImage(data: mantra.image!) : UIImage(named: Constants.defaultImage)
        let downsampledMantraImage = mantraImage?.resize(to: setPhotoButton.bounds.size)
        setPhotoButton.setImage(downsampledMantraImage, for: .normal)
    }
    
    private func setupUI() {
        
        titleStackView.customize(backgroundColor: .secondarySystemGroupedBackground, radiusSize: 15)
        mantraTextStackView.customize(backgroundColor: .secondarySystemGroupedBackground, radiusSize: 15)
        descriptionStackView.customize(backgroundColor: .secondarySystemGroupedBackground, radiusSize: 15)
        
        titleLabel.text = NSLocalizedString("TITLE", comment: "Mantra title label")
        mantraTextLabel.text = NSLocalizedString("MANTRA TEXT", comment: "Mantra text label")
        detailsTextLabel.text = NSLocalizedString("DESCRIPTION", comment: "Mantra description label")
        titleTextField.placeholder = NSLocalizedString("Enter mantra title", comment: "Mantra title placeholder")
        titleTextField.font = UIFont.preferredFont(for: .title2, weight: .medium)
        titleTextField.adjustsFontForContentSizeCategory = true
        mantraTextTextView.placeHolderText = NSLocalizedString("Enter mantra text", comment: "Mantra text placeholder")
        detailsTextView.placeHolderText = NSLocalizedString("Enter mantra description", comment: "Mantra description placeholder")
        
        setPhotoButton.showsMenuAsPrimaryAction = true
        let photoLibraryAction = UIAction(title: NSLocalizedString("Photo Library", comment: "Menu Item on DetailsViewController"),
                                          image: UIImage(systemName: "photo.on.rectangle.angled")) { [weak self] _ in
            guard let self = self else { return }
            self.showImagePicker()
        }
        let standardImageAction = UIAction(title: NSLocalizedString("Standard Image", comment: "Menu Item on DetailsViewController"),
                                           image: UIImage(systemName: "photo")) { [weak self] _ in
            guard let self = self else { return }
            self.setDefaultImage()
        }
        let searchAction = UIAction(title: NSLocalizedString("Search on the Internet", comment: "Menu Item on DetailsViewController"),
                                    image: UIImage(systemName: "globe")) { [weak self] _ in
            guard let self = self else { return }
            self.searchOnTheInternet()
        }
        let photoMenu = UIMenu(children: [photoLibraryAction, standardImageAction, searchAction])
        setPhotoButton.menu = photoMenu
        
        setMode()
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Add", comment: "Button on MantraTableViewController"),
                                                            primaryAction: UIAction(handler: { [weak self] _ in
                                                                guard let self = self else { return }
                                                                self.addButtonPressed()
                                                            }))
        navigationItem.rightBarButtonItem?.style = .done
        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .cancel,
                                                           primaryAction: UIAction(handler: { [weak self] _ in
                                                            guard let self = self else { return }
                                                            self.cancelButtonPressed()
                                                           }))
        navigationItem.rightBarButtonItem?.isEnabled = (titleTextField.text != "")
        setPhotoButton.setEditMode()
        titleTextField.isUserInteractionEnabled = true
        mantraTextTextView.isEditable = true
        detailsTextView.isEditable = true
        titleTextField.becomeFirstResponder()
        mantraTextTextView.placeHolder.isHidden = !mantraTextTextView.text.isEmpty
        detailsTextView.placeHolder.isHidden = !detailsTextView.text.isEmpty
    }
    
    private func setEditMode() {
        title = NSLocalizedString("Information", comment: "Information bar title")
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .done,
                                                            primaryAction: UIAction(handler: { [weak self] _ in
                                                                guard let self = self else { return }
                                                                self.doneButtonPressed()
                                                            }))
        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .close,
                                                           primaryAction: UIAction(handler: { [weak self] _ in
                                                            guard let self = self else { return }
                                                            self.closeButtonPressed()
                                                           }))
        setPhotoButton.setEditMode()
        titleTextField.isUserInteractionEnabled = true
        mantraTextTextView.isEditable = true
        detailsTextView.isEditable = true
        titleTextField.becomeFirstResponder()
        mantraTextTextView.placeHolder.isHidden = !mantraTextTextView.text.isEmpty
        detailsTextView.placeHolder.isHidden = !detailsTextView.text.isEmpty
    }
    
    private func setViewMode() {
        navigationItem.title = NSLocalizedString("Information", comment: "Information bar title")
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .edit,
                                                            primaryAction: UIAction(handler: { [weak self] _ in
                                                                guard let self = self else { return }
                                                                self.editButtonPressed()
                                                            }))
        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .close,
                                                           primaryAction: UIAction(handler: { [weak self] _ in
                                                            guard let self = self else { return }
                                                            self.closeButtonPressed()
                                                           }))
        setPhotoButton.setViewMode()
        titleTextField.isUserInteractionEnabled = false
        mantraTextTextView.isEditable = false
        detailsTextView.isEditable = false
        titleTextField.resignFirstResponder()
        mantraTextTextView.resignFirstResponder()
        detailsTextView.resignFirstResponder()
        mantraTextTextView.placeHolder.isHidden = true
        detailsTextView.placeHolder.isHidden = true
    }
}

//MARK: - Navigation Bar Buttons Methods

extension DetailsViewController {
    
    private func addButtonPressed() {
        guard let title = titleTextField.text else { return }
        if isMantraDuplicating(for: title) {
            showDuplicatingAlert(for: title)
        } else {
            handleAddNewMantra(for: title)
        }
    }
    
    private func cancelButtonPressed() {
        context.delete(mantra)
        dismiss(animated: true, completion: nil)
    }
    
    private func editButtonPressed() {
        mode = .edit
    }
    
    private func doneButtonPressed() {
        guard let title = titleTextField.text else { return }
        processMantra(title: title)
        delegate?.updateView()
        mode = .view
    }
    
    private func closeButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    private func isMantraDuplicating(for title: String) -> Bool {
        guard let mantraTitles = mantraTitles else { return false }
        return mantraTitles.contains(title)
    }
    
    private func showDuplicatingAlert(for title: String) {
        let alert = UIAlertController.duplicatingAlert {
            self.handleAddNewMantra(for: title)
        } cancelActionHandler: { return }
        present(alert, animated: true, completion: nil)
    }
    
    private func handleAddNewMantra(for title: String) {
        processMantra(title: title)
        dismiss(animated: true, completion: nil)
    }
    
    private func processMantra(title: String) {
        mantra.title = title
        mantra.text = mantraTextTextView.text
        mantra.details = detailsTextView.text
        mantra.image = mantraImageData ?? nil
        mantra.imageForTableView = mantraImageForTableViewData ?? nil
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
        setPhotoButton.setImage(UIImage(named: Constants.defaultImage), for: .normal)
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
        guard let search = titleTextField.text else { return }
        guard let urlString = "https://www.google.com/search?q=\(search)&tbm=isch"
                .addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else { return }
        guard let url = URL(string: urlString) else { return }
        let vc = SFSafariViewController(url: url)
        vc.delegate = self
        vc.modalPresentationStyle = .pageSheet
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
        navigationItem.rightBarButtonItem?.isEnabled = (textField.text != "")
    }
}

//MARK: - TextView Delegate (Handling TextViews Placeholders)

extension DetailsViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        mantraTextTextView.placeHolder.isHidden = !mantraTextTextView.text.isEmpty
        detailsTextView.placeHolder.isHidden = !detailsTextView.text.isEmpty
    }
}

//MARK: - PHPickerViewController Delegate

extension DetailsViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        
        guard !results.isEmpty else { return }
        
        setPhotoButton.setProcessMode()
        
        for result in results {
            let provider = result.itemProvider
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self, completionHandler: { [weak self] (object, _) in
                    guard let self = self else { return }
                    if let image = object as? UIImage {
                        let resultImage = self.processImage(image: image)
                        DispatchQueue.main.async {
                            let downsampledImage = resultImage?.resize(to: self.setPhotoButton.bounds.size)
                            self.setPhotoButton.setImage(downsampledImage, for: .normal)
                            self.setPhotoButton.setEditMode()
                            self.addTransition()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.setPhotoButton.setEditMode()
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

//MARK: - SFSafariViewController Delegate

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
        let downsampledImage = resultImage?.resize(to: setPhotoButton.bounds.size)
        setPhotoButton.setImage(downsampledImage, for: .normal)
    }
}

//MARK: - UIAdaptivePresentationController Delegate (Handling dismisson of modal view)

extension DetailsViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if delegate is MantraViewController {
            context.delete(mantra)
        }
    }
}
