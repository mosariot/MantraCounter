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
    var savedShortCutItem: UIApplicationShortcutItem!
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        if let shortcutItem = connectionOptions.shortcutItem {
            savedShortCutItem = shortcutItem
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
            case "com.mosariot.MantraCounter.favorites":
                mantraTableViewController.setFavoriteMode()
            case "com.mosariot.MantraCounter.addNewMantra":
                mantraTableViewController.setAddNewMantraMode()
            case "com.mosariot.MantraCounter.search":
                mantraTableViewController.setSearchMode()
            default:
                break
            }
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        if savedShortCutItem != nil {
            handleShortcutAction(shortcutItem: savedShortCutItem)
        }
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}

