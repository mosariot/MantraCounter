//
//  ReadsCountView.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 29.06.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

final class ReadsCountView: UIView {
    
    @IBOutlet var portraitMantraImageView: UIImageView!
    @IBOutlet var landscapeMantraImageView: UIImageView!
    @IBOutlet var titleLabel: CopyableLabel!
    @IBOutlet var addRoundsButton: AdjustReadsButton!
    @IBOutlet var addReadsButton: AdjustReadsButton!
    @IBOutlet var setProperValueButton: AdjustReadsButton!
    @IBOutlet var circularProgressView: CircularProgressView!
    @IBOutlet var readsGoalButton: UIButton!
    @IBOutlet var mainStackView: UIStackView!
    @IBOutlet var displayAlwaysOn: UIButton!
    
    @objc func doubleTapped() {
        print("double view")
    }
    
    @objc func tripleTapped() {
        print("triple view")
    }
}
