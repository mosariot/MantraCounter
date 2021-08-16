//
//  DetailsViewControllerState.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 09.08.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

protocol DetailsStateContext: UIViewController {
    
    var detailsView: DetailsView! { get }
    var mantraHandler: DetailsButtonsHandler { get }
}

class DetailsViewControllerState {
    
    func apply(to context: DetailsStateContext) {}
}

extension DetailsViewControllerState {
    
    static func addDetailsState() -> AddDetailsState {
        AddDetailsState()
    }
    
    static func editDetailsState() -> EditDetailsState {
        EditDetailsState()
    }
    
    static func viewDetailsState() -> ViewDetailsState {
        ViewDetailsState()
    }
}
