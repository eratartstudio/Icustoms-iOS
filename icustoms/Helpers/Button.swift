//
//  Button.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 22/03/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit

class Button: UIButton {
    
    private let activeColor: UIColor = UIColor(red: 253/255, green: 102/255, blue: 0, alpha: 1)
    private let inactiveColor: UIColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    private let activeTitleColor: UIColor = .white
    private let inactiveTitleColor: UIColor = UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1)
    
    override var isEnabled: Bool {
        didSet {
            setTitleColor(isEnabled ? activeTitleColor : inactiveTitleColor, for: .normal)
            backgroundColor = isEnabled ? activeColor : inactiveColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let enabled = isEnabled
        isEnabled = enabled
        layer.cornerRadius = 6
        clipsToBounds = true
    }
    
}
