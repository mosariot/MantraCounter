//
//  CopyableLabel.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 19.10.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

final class CopyableLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    func sharedInit() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(showMenu(sender:))))
    }
    
    override public var canBecomeFirstResponder: Bool {
        true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(UIResponderStandardEditActions.copy)
    }
    
    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
        UIMenuController.shared.hideMenu(from: self)
    }
    
    @objc func showMenu(sender: Any?) {
        becomeFirstResponder()
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            menu.showMenu(from: self, rect: bounds)
        }
    }
}
