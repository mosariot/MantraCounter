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
    private let defaults = UserDefaults.standard
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard
            let splitViewController = window?.rootViewController as? UISplitViewController,
            let leftNavController = splitViewController.viewControllers.first as? UINavigationController,
            let primaryViewController = leftNavController.viewControllers.first as? MantraViewController,
            let secondaryViewController = (splitViewController.viewControllers.last as? UINavigationController)?.topViewController as? ReadsCountViewController
        else { fatalError() }
        
        defaults.set(true, forKey: "collapseSecondaryViewController")
        
        splitViewController.delegate = self
        splitViewController.preferredDisplayMode = .oneBesideSecondary
        splitViewController.preferredPrimaryColumnWidthFraction = 0.5
        splitViewController.maximumPrimaryColumnWidth = 400
        primaryViewController.delegate = secondaryViewController
        secondaryViewController.mantraDataManager = primaryViewController.mantraDataManager
        
        if let url = connectionOptions.urlContexts.first?.url {
            let uuid = UUID(uuidString: "\(url)")
            deepLinkToSpecificMantra(with: uuid)
        }
        
        if let shortcutItem = connectionOptions.shortcutItem {
            splitViewController.show(.primary)
            splitViewController.dismiss(animated: false, completion: nil)
            leftNavController.popToRootViewController(animated: false)
            handleShortcutAction(for: shortcutItem, controller: primaryViewController)
        }
        
        listenForFatalCoreDataNotifications()
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
            controller.setAddNewMantraMode()
        case "com.mosariot.MantraCounter.search":
            controller.setSearchMode()
        default:
            break
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            let uuid = UUID(uuidString: "\(url)")
            deepLinkToSpecificMantra(with: uuid)
        }
    }
    
    private func deepLinkToSpecificMantra(with id: UUID?) {
        guard
            let id = id,
            let splitViewController = window?.rootViewController as? UISplitViewController,
            let leftNavController = splitViewController.viewControllers.first as? UINavigationController,
            let primaryViewController = leftNavController.viewControllers.first as? MantraViewController
        else { return }
        
        splitViewController.dismiss(animated: false, completion: nil)
        leftNavController.popToRootViewController(animated: false)
        
        primaryViewController.goToMantraWith(id)
    }
}

extension SceneDelegate: UISplitViewControllerDelegate {
    
    func splitViewController(_ svc: UISplitViewController,
                             topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
        defaults.bool(forKey: "collapseSecondaryViewController") ? .primary : .secondary
    }
}

//MARK: - Core Data Fatal Errors

extension SceneDelegate {
    
    func listenForFatalCoreDataNotifications() {
        NotificationCenter.default.addObserver(forName: dataSaveFailedNotification, object: nil, queue: OperationQueue.main) { _ in
            guard let splitViewController = self.window?.rootViewController as? UISplitViewController else { return }
            AlertCenter.dataSaveFailedAlert(in: splitViewController)
        }
    }
}
