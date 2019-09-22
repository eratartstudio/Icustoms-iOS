//
//  RussianLanguageCell.swift
//  icustoms
//
//  Created by Danik's MacBook on 05/06/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit

class RussianLanguageCell: UITableViewCell {
    
    let langStr = Locale.current.languageCode
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if langStr == "ru" {
            accessoryType = .checkmark
            isUserInteractionEnabled = false
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
