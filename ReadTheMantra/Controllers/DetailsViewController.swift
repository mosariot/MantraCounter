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

final class DetailsViewController: UIViewController, DetailsStateContext, DetailsButtonHandlerContext {
    
    //MARK: - Properties
    
    private(set) var mantraManager: DataManager = MantraManager()
    lazy var buttonsHandler = DetailsButtonsHandler(context: self)
    
    var detailsView: DetailsView! {
        guard isViewLoaded else { return nil }
        return (view as! DetailsView)
    }
    
    private(set) var states: (addState: DetailsViewControllerState,
                         editState: DetailsViewControllerState,
                         viewState: DetailsViewControllerState) =
        (addState: AddDetailsState(),
         editState: EditDetailsState(),
         viewState: ViewDetailsState())
    lazy var currentState: DetailsViewControllerState = states.viewState {
        didSet { currentState.apply(to: self) }
    }
    private var initialState: DetailsViewControllerState
    
    let addHapticGenerator = UINotificationFeedbackGenerator()
    private let pasteboard = UIPasteboard.general
    
    private(set) var mantraImageData: Data?
    private(set) var mantraImageForTableViewData: Data?
    
    private(set) var mantra: Mantra
    private(set) var mantraTitles: [String]?
    private weak var callerController: UIViewController?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Init
    
    init?(mantra: Mantra,
          state: DetailsViewControllerState,
          mantraTitles: [String]? = nil,
          callerController: UIViewController? = nil,
          coder: NSCoder) {
        self.mantra = mantra
        self.initialState = state
        self.mantraTitles = mantraTitles
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
        setState()
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
        
        detailsView.titleTextField.autocorrectionType = .no
        detailsView.mantraTextTextView.autocorrectionType = .no
        
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
        if type(of: currentState) != ViewDetailsState.self && !detailsView.titleTextField.isFirstResponder {
            detailsView.titleTextField.becomeFirstResponder()
            let newPosition = detailsView.titleTextField.endOfDocument
            detailsView.titleTextField.selectedTextRange = detailsView.titleTextField.textRange(from: newPosition, to: newPosition)
        }
    }
    
    @objc private func showTextKeyboard(_ recognizer: UIGestureRecognizer) {
        if type(of: currentState) != ViewDetailsState.self && !detailsView.mantraTextTextView.isFirstResponder {
            detailsView.mantraTextTextView.becomeFirstResponder()
            let newPosition = detailsView.mantraTextTextView.endOfDocument
            detailsView.mantraTextTextView.selectedTextRange = detailsView.mantraTextTextView.textRange(from: newPosition, to: newPosition)
        }
    }
    
    @objc private func showDescriptionKeyboard(_ recognizer: UIGestureRecognizer) {
        if type(of: currentState) != ViewDetailsState.self && !detailsView.detailsTextView.isFirstResponder {
            detailsView.detailsTextView.becomeFirstResponder()
            let newPosition = detailsView.detailsTextView.endOfDocument
            detailsView.detailsTextView.selectedTextRange = detailsView.detailsTextView.textRange(from: newPosition, to: newPosition)
        }
    }
    
    private func setState() {
        switch initialState {
        case is AddDetailsState:
            currentState = states.addState
        case is EditDetailsState:
            currentState = states.editState
        case is ViewDetailsState:
            currentState = states.viewState
        default:
            currentState = states.viewState
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
