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
    var lastSelection: IndexPath!
    let langStr = Locale.current.languageCode
    
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
    
    func changeAppLanguage(_ language: String) {
        let alert = UIAlertController(title: "Выберите язык".localizedSafe, message: "Для смены языка, необходимо перезапустить приложение".localizedSafe, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Отмена".localizedSafe, style: .cancel, handler: { (action) in
            self.tableView.cellForRow(at: self.lastSelection)?.accessoryType = .none
        }))
        
        alert.addAction(UIAlertAction(title: "Перезапустить".localizedSafe, style: .default, handler: { (action) in
            UserDefaults.standard.set([language], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            // Closeng app for change localisation
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                exit(0)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.lastSelection != nil {
            self.tableView.cellForRow(at: self.lastSelection)?.accessoryType = .none
        }
        
        switch indexPath.row {
        case 0:
            // Russian
            changeAppLanguage("ru")
        case 1:
            // English
            changeAppLanguage("en")
        case 2:
            // Chinese
            changeAppLanguage("zh")
        default:
            break
        }
        
        self.lastSelection = indexPath
        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}
