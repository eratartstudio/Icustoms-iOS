//
//  ViewController.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 21/03/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


}


extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ActiveOrderTableCell.self, for: indexPath)
        
        return cell
    }
    
}

import UICircularProgressRing

class ActiveOrderTableCell: UITableViewCell {
    
    @IBOutlet weak var analyticsCircleView: UICircularProgressRing!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        analyticsCircleView.minValue = 0
        analyticsCircleView.maxValue = 100
        analyticsCircleView.value = 30
    }
    
}
