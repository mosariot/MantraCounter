//
//  TextDelegateHandler.swift
//  ReadTheMantra
//
//  Created by Александр Воробьев on 30.11.2021.
//  Copyright © 2021 Александр Воробьев. All rights reserved.
//

import UIKit

final class TextDelegateHandler: NSObject {
    
    private var textFieldDidChangeSelectionContinuation: AsyncStream<Bool>.Continuation?
    private var textViewContinuation: AsyncStream<Void>.Continuation?
    
    convenience init(textViews: UITextView..., textFields: UITextField...) {
        self.init()
        textViews.forEach { $0.delegate = self }
        textFields.forEach { $0.delegate = self }
    }
    
    func listenForTextFieldChangeSelection() async -> AsyncStream<Bool> {
        AsyncStream<Bool> { continuation in self.textFieldDidChangeSelectionContinuation = continuation }
    }
    
    func listenForTextViewChange() async -> AsyncStream<Void> {
        AsyncStream<Void> { continuation in self.textViewContinuation = continuation }
    }
    
    deinit {
        textFieldDidChangeSelectionContinuation?.finish()
        textViewContinuation?.finish()
    }
}

extension TextDelegateHandler: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let isThereAnySymbols = textField.text?.trimmingCharacters(in: .whitespaces) != ""
        textFieldDidChangeSelectionContinuation?.yield(isThereAnySymbols)
    }
}

extension TextDelegateHandler: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textViewContinuation?.yield()
    }
}
