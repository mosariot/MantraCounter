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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            goToMantraTableViewController()
        }
        
        func goToMantraTableViewController() {
            if let mantraTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MantraTableViewController") as? UITableViewController {
                self.navigationController?.pushViewController(mantraTableViewController, animated: true)
            }
        }
    }
}
