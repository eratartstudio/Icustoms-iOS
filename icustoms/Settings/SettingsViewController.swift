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
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        settings = Database.default.profileSettings
        
        API.default.profileSettings(success: { (settings) in
            if let settings = settings {
                self.settings = settings
                Database.default.profileSettings = settings
                self.updateSwitches()
            }
        }) { (error, statusCode) in
            print("\(statusCode) - \(error.localizedDescription)")
        }
    }
    
    func updateSwitches() {
        guard settings != nil else { return }
        let pushSettings = settings.pushNotification
        statusNotificationSwitch.isOn = pushSettings.status
        balanceNotificationSwitch.isOn = pushSettings.balance
        otherNotificationSwitch.isOn = pushSettings.other
    }
    
    @IBAction func switchDidChange() {
        let pushSettings = PushNotificationSettings(status: statusNotificationSwitch.isOn, balance: balanceNotificationSwitch.isOn, other: otherNotificationSwitch.isOn)
        settings = ProfileSettings(pushNotification: pushSettings)
        Database.default.profileSettings = settings
        API.default.updateProfileSettings(settings, success: { (flag) in
        }) { (error, statusCode) in
            print("\(statusCode) - \(error.localizedDescription)")
        }
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
        if indexPath.section == 1 {
            if self.lastSelection != nil {
                self.tableView.cellForRow(at: self.lastSelection)?.accessoryType = .none
            }
            
            switch (indexPath.row, indexPath.section) {
            case (0, 1):
                // Russian
                changeAppLanguage("ru")
            case (1, 1):
                // English
                changeAppLanguage("en")
            case (2, 1):
                // Chinese
                changeAppLanguage("zh")
            default:
                UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
                UserDefaults.standard.synchronize()
            }
            
            self.lastSelection = indexPath
            self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
