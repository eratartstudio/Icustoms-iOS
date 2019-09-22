//
//  NotificationItemTableCell.swift
//  icustoms
//
//  Created by Danik's MacBook on 22/09/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit

class NotificationItemTableCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activeSwitch: UISwitch!
    
    var index: Int = 0
    weak var controller: NotificationsViewController?
    
    @IBAction func switchDidChange() {
        if controller?.isSms == true {
            controller?.sms[index] = activeSwitch.isOn
        } else {
            controller?.email[index] = activeSwitch.isOn
        }
    }
}
