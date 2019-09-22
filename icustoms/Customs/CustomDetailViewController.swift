//
//  CustomDetailViewController.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 08/04/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit

class CustomDetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var totalAvansLabel: UILabel!
    @IBOutlet weak var totalTollLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var custom: Custom!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        titleLabel.text = custom.custom.name.localizedSafe
        totalAvansLabel.text = getStringWithSpace(string: String(custom.totalAvans)) + " ₽"//String(format: "%.2f", custom.totalAvans) + " ₽"
        totalTollLabel.text = getStringWithSpace(string: String(custom.totalToll)) + " ₽"//String(format: "%.2f", custom.totalToll) + " ₽"
    }
}

extension CustomDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section == 1 else { return nil }
        return "Остатки актуальны на ".localizedSafe + Date.from(string: custom.actualDate, format: "yyyy-MM-dd'T'HH:mm:ssZZZ").string(with: "dd.MM.yyyy HH:mm")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? custom.customPayments.count + 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomPaymentTitleTableCell", for: indexPath)
            return cell
        }
        let cell = tableView.dequeueReusableCell(CustomPaymentTableCell.self, for: indexPath)
        cell.payment = custom.customPayments[indexPath.row - 1]
        return cell
    }
}
