//
//  NotificationsViewController.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 04/04/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit
import DKExtensions

class NotificationsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var isSms: Bool = true
    
    let titles: [String] = [
        "Создан заказ".localizedSafe,
        "ДТ зарегистрирована".localizedSafe,
        "ДТ на проверке".localizedSafe,
        "ДТ на досмотре".localizedSafe,
        "ДТ на проверке, досмотр завершен".localizedSafe,
        "ДТ выпуск".localizedSafe,
        "ДТ осуществляется досмотр".localizedSafe,
        "ДТ досмотр завершен, ДТ на проверке".localizedSafe
    ]
    var sms: [Bool] = []
    var email: [Bool] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.isHidden = true
        
        API.default.emailSettings(success: { [weak self] (response) in
            guard let result = response?.array else {
                self?.showAlert("Ошибка".localizedSafe, message: "Невозможно отобразить данные".localizedSafe)
                return
            }
            self?.email = result
            self?.updateContent()
        }) { [weak self] (error, status) in
            self?.showAlert("Ошибка".localizedSafe, message: "Невозможно загрузить данные".localizedSafe)
        }
        
        API.default.smsSettings(success: { [weak self] (response) in
            guard let result = response?.array else {
                self?.showAlert("Ошибка".localizedSafe, message: "Невозможно отобразить данные".localizedSafe)
                return
            }
            self?.sms = result
            self?.updateContent()
        }) { [weak self] (error, status) in
            self?.showAlert("Ошибка".localizedSafe, message: "Невозможно загрузить данные".localizedSafe)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        API.default.updateEmailSettings(email)
        API.default.updateSmsSettings(sms)
    }
    
    @IBAction func changeSource() {
        isSms = segmentedControl.selectedSegmentIndex == 0
        updateContent()
    }
    
    func updateContent() {
        guard !sms.isEmpty && !email.isEmpty else { return }
        activityIndicator.stopAnimating()
        tableView.isHidden = false
        tableView.reloadData()
    }
    
}

extension NotificationsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSms ? sms.count : email.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(NotificationItemTableCell.self, for: indexPath)
        cell.index = indexPath.row
        cell.controller = self
        cell.titleLabel.text = titles[indexPath.row]
        cell.activeSwitch.isOn = isSms ? sms[indexPath.row] : email[indexPath.row]
        return cell
    }
    
}

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
