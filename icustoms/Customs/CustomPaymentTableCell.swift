//
//  CustomPaymentTableCell.swift
//  icustoms
//
//  Created by Danik's MacBook on 22/09/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit

class CustomPaymentTableCell: UITableViewCell {
    
    @IBOutlet weak var kbkLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var sumLabel: UILabel!
    
    var payment: CustomPayment? {
        didSet {
            updateContent()
        }
    }
    
    private func updateContent() {
        guard let payment = payment else { return }
        kbkLabel.text = payment.kbk
        typeLabel.text = payment.type == 1 ? "Аванс".localizedSafe : "Пошлина".localizedSafe
        sumLabel.text = String(payment.sum)
    }
}
