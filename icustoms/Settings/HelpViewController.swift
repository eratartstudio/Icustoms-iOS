//
//  HelpViewController.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 27/03/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    
    let phone: String = "+74996776484"
    
    @IBAction func callAction() {
        let url = URL(string: "tel://" + phone)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
}
