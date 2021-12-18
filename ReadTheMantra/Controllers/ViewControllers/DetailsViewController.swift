//
//  DetailsViewController.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 02.08.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit
import SafariServices

final class DetailsViewController: UIViewController, DetailsStateContext, DetailsButtonHandlerContext {
    
    //MARK: - Properties
    
    let mantraDataManager: DataManager
    private(set) lazy var buttonsHandler: DetailsButtonsHandler = MantraDetailsButtonsHandler(context: self)
    
    var detailsView: DetailsView! {
        guard isViewLoaded else { return nil }
        return (view as! DetailsView)
    }
    
    private(set) var states: (addState: DetailsViewControllerState,
                         editState: DetailsViewControllerState,
                         viewState: DetailsViewControllerState) =
        (addState: .addDetailsState(),
         editState: .editDetailsState(),
         viewState: .viewDetailsState())
    lazy var currentState: DetailsViewControllerState = states.viewState {
        didSet { currentState.apply(to: self) }
    }
    private var initialState: DetailsViewControllerState
    
    let addHapticGenerator = UINotificationFeedbackGenerator()
    
    private(set) var mantraImageData: Data?
    private(set) var mantraImageForTableViewData: Data?
    
    private(set) var mantra: Mantra
    private(set) var mantraTitles: [String]
    private weak var callerController: UIViewController?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Init
    
    init?(mantra: Mantra,
          state: DetailsViewControllerState,
          mantraDataManager: DataManager,
          callerController: UIViewController? = nil,
          coder: NSCoder) {
        self.mantra = mantra
        self.initialState = state
        self.mantraDataManager = mantraDataManager
        self.mantraTitles = mantraDataManager.fetchedMantras.compactMap { $0.title }
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
        
        let textDelegateHandler = TextDelegateHandler(
            textViews: detailsView.mantraTextTextView, detailsView.detailsTextView,
            textFields: detailsView.titleTextField)
        Task { await listenForTextFieldChange(textDelegateHandler) }
        Task { await listenForTextViewChange(textDelegateHandler) }
        
        addHapticGenerator.prepare()
        
        setupData()
    }
    
    @MainActor
    private func listenForTextFieldChange(_ textDelegateHandler: TextDelegateHandler) async {
        for await isThereAnySymbols in await textDelegateHandler.listenForTextFieldChangeSelection() {
            navigationItem.rightBarButtonItem?.isEnabled = isThereAnySymbols
        }
    }
    
    @MainActor
    private func listenForTextViewChange(_ textDelegateHandler: TextDelegateHandler) async {
        for await _ in await textDelegateHandler.listenForTextViewChange() {
            detailsView.mantraTextTextView.placeHolder.isHidden = !detailsView.mantraTextTextView.text.isEmpty
            detailsView.detailsTextView.placeHolder.isHidden = !detailsView.detailsTextView.text.isEmpty
        }
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
        
        detailsView.setup()
        
        detailsView.setPhotoButtonMenu (
            imagePickerHandler: { [weak self] in
                guard let self = self else { return }
                Task { await self.getImageFromGallery() }},
            defaultImageHandler: { [weak self] in
                guard let self = self else { return }
                self.setDefaultImage()},
            searchOnTheInternetHandler: { [weak self] in
                guard let self = self else { return }
                Task { await self.getImageFromSafari(with: self.detailsView.titleTextField.text ?? "") }
            })
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
    
    @MainActor
    private func getImageFromGallery() async {
        let galleryImagePicker = GalleryImagePicker(in: self)
        do {
            let image = try await galleryImagePicker.getImage()
            detailsView.setPhotoButton.setProcessMode()
            let resultImage = self.processImage(image: image)
            let downsampledImage = resultImage?.resize(to: self.detailsView.setPhotoButton.bounds.size)
            self.detailsView.setPhotoButton.setImage(downsampledImage, for: .normal)
            self.detailsView.setPhotoButton.setEditMode()
            self.addTransition()
        } catch {
            self.detailsView.setPhotoButton.setEditMode()
            Task { await self.showNoImageAlert() }
        }
    }
    
    private func showNoImageAlert() async {
        if await AlertCenter.confirmNoValidImage(in: self) {
            await getImageFromGallery()
        }
    }
    
    private func addTransition() {
        let transition = CATransition()
        transition.type = .fade
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: .easeOut)
        view.layer.add(transition, forKey: nil)
    }
    
    private func setDefaultImage() {
        detailsView.setPhotoButton.setImage(UIImage(named: Constants.defaultImage), for: .normal)
        addTransition()
        mantraImageData = nil
        mantraImageForTableViewData = nil
    }
    
    private func getImageFromSafari(with search: String) async {
        let safariImagePicker = SafariImagePicker(in: self, search: search)
        let image = await safariImagePicker.getImage()
        let resultImage = processImage(image: image)
        await MainActor.run {
            let downsampledImage = resultImage?.resize(to: detailsView.setPhotoButton.bounds.size)
            detailsView.setPhotoButton.setImage(downsampledImage, for: .normal)
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
