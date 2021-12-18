//
//  SearchControllerHandler.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 29.11.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

final class SearchControllerHandler: NSObject {
    
    private var searchResultsContinuation: AsyncStream<Void>.Continuation?
    private var dismissContinuation: AsyncStream<Void>.Continuation?
    
    init(_ searchController: UISearchController) {
        super.init()
        searchController.searchResultsUpdater = self
        searchController.delegate = self
    }
    
    func listenForSearchUpdating() async -> AsyncStream<Void> {
        AsyncStream<Void> { continuation in self.searchResultsContinuation = continuation }
    }
    
    func listenForSearchControllerDismiss() async -> AsyncStream<Void> {
        AsyncStream<Void> { continuation in self.dismissContinuation = continuation }
    }
    
    deinit {
        searchResultsContinuation?.finish()
        dismissContinuation?.finish()
    }
}

extension SearchControllerHandler: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchResultsContinuation?.yield()
    }
}

extension SearchControllerHandler: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        dismissContinuation?.yield()
    }
}
