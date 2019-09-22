//
//  RemainTableCell.swift
//  icustoms
//
//  Created by Danik's MacBook on 22/09/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit

class RemainTableCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avansLabel: UILabel!
    @IBOutlet weak var tollLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var custom: Custom? {
        didSet {
            updateContent()
        }
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
    
    private func updateContent() {
        guard let custom = custom else { return }
        titleLabel.text = custom.custom.name.localizedSafe
        avansLabel.text = getStringWithSpace(string: String(custom.totalAvans)) + " ₽"//String(format: "%.2f", custom.totalAvans) + " ₽"
        tollLabel.text = getStringWithSpace(string: String(custom.totalToll)) + " ₽"//String(format: "%.2f", custom.totalToll) + " ₽"
        dateLabel.text = Date.from(string: custom.actualDate, format: "yyyy-MM-dd'T'HH:mm:ssZZZ").string(with: "dd.MM.yyyy HH:mm")
    }
}
