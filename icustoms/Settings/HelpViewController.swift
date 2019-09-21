//
//  HelpViewController.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 27/03/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    
    let phone: String = "88005515147"
    let email = "info@icustoms.ru"
    
    @IBAction func callAction() {
        let url = URL(string: "telprompt://\(phone)")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func emailAction(_ sender: Any) {
        let url = URL(string: "mailto:\(email)")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
