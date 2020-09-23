//
//  LaunchViewController.swift
//  ReadTheMantra
//
//  Created by Александр Воробьев on 04.09.2020.
//  Copyright © 2020 Александр Воробьев. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            self.goToMantraTableViewController()
        }
    }
    
    private func goToMantraTableViewController() {
        if let mantraTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: K.mantraTableViewControllerID) as? UITableViewController {
            show(mantraTableViewController, sender: self)
        }
    }
}
