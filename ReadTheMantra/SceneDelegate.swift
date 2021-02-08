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
        guard let _ = (scene as? UIWindowScene) else { return }
        
        if let shortcutItem = connectionOptions.shortcutItem {
            handleShortcutAction(shortcutItem: shortcutItem)
        }
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        handleShortcutAction(shortcutItem: shortcutItem)
        completionHandler(true)
    }
    
    private func handleShortcutAction(shortcutItem: UIApplicationShortcutItem) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        if let mantraTableViewController = storyBoard.instantiateViewController(withIdentifier: Constants.mantraViewControllerID) as? MantraViewController {
            let navigationController = UINavigationController(rootViewController: mantraTableViewController)
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
            
            switch shortcutItem.type {
            case "com.mosariot.MantraCounter.addNewMantra":
                mantraTableViewController.setAddNewMantraMode()
            case "com.mosariot.MantraCounter.search":
                mantraTableViewController.setSearchMode()
            default:
                break
            }
        }
    }
}

