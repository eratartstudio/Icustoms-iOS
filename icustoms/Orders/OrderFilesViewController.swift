//
//  OrderFilesViewController.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 04/04/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit

class OrderFilesViewController: UIViewController {
    
    var order: Order!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        API.default.files(order.id, {
            
        }) { (error, status) in
            
        }
    }
    
}
