//
//  DetailsButtonsHandler.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 20.08.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

protocol DetailsButtonsHandler {
    
    func addButtonPressed()
    func cancelButtonPressed(_ sender: UIBarButtonItem?)
    func editButtonPressed()
    func doneButtonPressed()
    func closeButtonPressed(_ sender: UIBarButtonItem?)
}
