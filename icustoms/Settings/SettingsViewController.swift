//
//  SettingsViewController.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 15/04/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var statusNotificationSwitch: UISwitch!
    @IBOutlet weak var balanceNotificationSwitch: UISwitch!
    @IBOutlet weak var otherNotificationSwitch: UISwitch!
    
    var settings: ProfileSettings!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settings = Database.default.profileSettings
        
        if settings == nil {
            API.default.profileSettings(success: { (settings) in
                if let settings = settings {
                    self.settings = settings
                    Database.default.profileSettings = settings
                    self.updateSwitches()
                }
            }) { (error, statusCode) in
                print("\(statusCode) - \(error.localizedDescription)")
            }
        } else {
            updateSwitches()
        }
    }
    
    func updateSwitches() {
        guard settings != nil else { return }
        let pushSettings = settings.pushNotification.pushNotification
        statusNotificationSwitch.isOn = pushSettings.status
        balanceNotificationSwitch.isOn = pushSettings.balance
        otherNotificationSwitch.isOn = pushSettings.other
    }
    
    @IBAction func switchDidChange() {
        guard settings != nil else { return }
        let pushSettings = PushNotificationSettings(status: statusNotificationSwitch.isOn, balance: balanceNotificationSwitch.isOn, other: otherNotificationSwitch.isOn)
        settings = ProfileSettings(pushNotification: ProfilePushSettings(pushNotification: pushSettings))
        Database.default.profileSettings = settings
    }
    
}
