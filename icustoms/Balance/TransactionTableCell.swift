//
//  TransactionTableCell.swift
//  icustoms
//
//  Created by Danik's MacBook on 22/09/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit

class TransactionTableCell: UITableViewCell {
    
    @IBOutlet weak var priceFirstLabel: UILabel!
    @IBOutlet weak var priceLastLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var transaction: BalanceTransaction? {
        didSet {
            update()
        }
    }
    
    private func update() {
        guard let transaction = transaction else { return }
        let price = transaction.amount.presentable()
        priceLastLabel.text = "." + price.last + " ₽"
        if transaction.transactionType == .substract {
            priceFirstLabel.text = price.first
            priceFirstLabel.textColor = .black
            priceLastLabel.textColor = .lightGray
        } else {
            priceFirstLabel.text = "+" + price.first
            priceFirstLabel.textColor = UIColor(red: 107/255, green: 187/255, blue: 92/255, alpha: 1) // 145 203 132
            priceLastLabel.textColor = UIColor(red: 145/255, green: 203/255, blue: 132/255, alpha: 1)
        }
        descriptionLabel.text = transaction.description
    }
}
