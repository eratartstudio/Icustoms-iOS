//
//  RemainsViewController.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 25/03/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit

class RemainsViewController: UIViewController {
    
    
    
}

extension RemainsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(RemainTableCell.self, for: indexPath)
        
        return cell
    }
    
}

class RemainTableCell: UITableViewCell {
    
}
