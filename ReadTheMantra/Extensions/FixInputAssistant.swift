//
//  FixInputAssistant.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 10.01.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import UIKit

extension UIView {
    
    func fixInputAssistant() {
        subviews.forEach { subview in
            if type(of: subview) is UITextField.Type {
                let item = (subview as! UITextField).inputAssistantItem
                item.leadingBarButtonGroups = []
                item.trailingBarButtonGroups = []
            } else if subview.subviews.count > 0 {
                subview.fixInputAssistant()
            }
            if type(of: subview) is UITextView.Type {
                let item = (subview as! UITextView).inputAssistantItem
                item.leadingBarButtonGroups = []
                item.trailingBarButtonGroups = []
            } else if subview.subviews.count > 0 {
                subview.fixInputAssistant()
            }
        }
    }
}
