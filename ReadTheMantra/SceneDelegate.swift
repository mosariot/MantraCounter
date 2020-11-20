//
//  SceneDelegate.swift
//  ReadTheMantra
//
//  Created by Александр Воробьев on 14.08.2020.
//  Copyright © 2020 Александр Воробьев. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func windowScene(_ windowScene: UIWindowScene, didUpdate previousCoordinateSpace: UICoordinateSpace, interfaceOrientation previousInterfaceOrientation: UIInterfaceOrientation, traitCollection previousTraitCollection: UITraitCollection) {
        
    }
    
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        if let shortcutItem = connectionOptions.shortcutItem {
            handleShortcutAction(shortcutItemType: shortcutItem.type)
        }
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        handleShortcutAction(shortcutItemType: shortcutItem.type)
        completionHandler(true)
    }
    
    private func handleShortcutAction(shortcutItemType: String) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        if let mantraTableViewController = storyBoard.instantiateViewController(withIdentifier: Constants.mantraTableViewControllerID) as? MantraTableViewController {
            let navigationController = UINavigationController(rootViewController: mantraTableViewController)
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
            
            switch shortcutItemType {
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
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        lockOrientation()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        unlockOrientation()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
    }
    
    private func lockOrientation() {
        if let currentOrientation = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation {
            switch currentOrientation {
            case .landscapeLeft:
                print("1")
                Orientation.lock(.landscapeLeft)
            case .landscapeRight:
                print("2")
                Orientation.lock(.landscapeRight)
            case .portrait:
                print("3")
                Orientation.lock(.portrait)
            case .portraitUpsideDown:
                print("4")
                Orientation.lock(.portraitUpsideDown)
            default:
                print("5")
                return
            }
        }
    }
    
    private func unlockOrientation() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            Orientation.lock(.all)
        }
    }
}

