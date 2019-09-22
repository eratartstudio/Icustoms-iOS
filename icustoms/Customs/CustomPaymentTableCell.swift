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
        sumLabel.text = getStringWithSpace(string: String(payment.sum))//payment.sum
    }
    
    func getStringWithSpace(string: String) -> String {
        let num = string.split(separator: ".")
        
        let numArray = Array(num[0])
        var reversedNumArray = [Character]()
        
        for arrayIndex in stride(from: numArray.count - 1, through: 0, by: -1) {
            reversedNumArray.append(numArray[arrayIndex])
        }
        
        let len = num[0].count
        var newStr = ""
        for curSymb in 1...len {
            newStr = String(reversedNumArray[curSymb-1]) + newStr
            if((curSymb % 3 == 0) && (curSymb != len)) {
                newStr = " " + newStr
            }
        }
        
        if(num.count > 1){
            newStr = newStr + "." + "\(num[1])".maxLength(length: 2)
        }
        return newStr
    }
}
