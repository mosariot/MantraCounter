//
//  SceneDelegate.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 14.08.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard
            let splitViewController = window?.rootViewController as? UISplitViewController,
            let leftNavController = splitViewController.viewControllers.first as? UINavigationController,
            let primaryViewController = leftNavController.viewControllers.first as? MantraViewController,
            let secondaryViewController = (splitViewController.viewControllers.last as? UINavigationController)?.topViewController as? ReadsCountViewController
        else { fatalError() }
        
        splitViewController.delegate = self
        splitViewController.view.tintColor = Constants.accentColor
        splitViewController.preferredDisplayMode = .oneBesideSecondary
        splitViewController.preferredPrimaryColumnWidthFraction = 0.5
        splitViewController.maximumPrimaryColumnWidth = 400
        primaryViewController.delegate = secondaryViewController
        
        if let shortcutItem = connectionOptions.shortcutItem {
            splitViewController.show(.primary)
            splitViewController.dismiss(animated: false, completion: nil)
            leftNavController.popToRootViewController(animated: false)
            handleShortcutAction(for: shortcutItem, controller: primaryViewController)
        }
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard
            let splitViewController = window?.rootViewController as? UISplitViewController,
            let leftNavController = splitViewController.viewControllers.first as? UINavigationController,
            let primaryViewController = leftNavController.viewControllers.first as? MantraViewController
        else { return }
        
        splitViewController.show(.primary)
        splitViewController.dismiss(animated: false, completion: nil)
        leftNavController.popToRootViewController(animated: false)
        
        handleShortcutAction(for: shortcutItem, controller: primaryViewController)
        completionHandler(true)
    }
    
    private func handleShortcutAction(for shortcutItem: UIApplicationShortcutItem, controller: MantraViewController) {
        switch shortcutItem.type {
        case "com.mosariot.MantraCounter.addNewMantra":
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                controller.setAddNewMantraMode()
            }
        case "com.mosariot.MantraCounter.search":
            controller.setSearchMode()
        default:
            break
        }
    }
}

extension SceneDelegate: UISplitViewControllerDelegate {
    
    func splitViewController(_ svc: UISplitViewController,
                             topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column)
    -> UISplitViewController.Column {
        let splitViewController = window?.rootViewController as? UISplitViewController
        let leftNavController = splitViewController?.viewControllers.first as? UINavigationController
        let primaryViewController = leftNavController?.viewControllers.first as? MantraViewController
        return (primaryViewController?.collapseSecondaryViewController ?? true) ? .primary : .secondary
    }
}
