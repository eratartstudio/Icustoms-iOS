//
//  ConfirmCodeViewController.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 22/03/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit
import SVProgressHUD

class ConfirmCodeViewController: UIViewController {
    
    var authorization: AuthorizationResponse!
    var phone: String!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var resendButton: Button!
    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var resendLabel: UILabel!
    @IBOutlet weak var confirmButton: Button!
    
    var isFirst: Bool = true
    //var local: Localization!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        //local = Localization.current()
        confirmButton.isHidden = true
        descriptionLabel.text = "Введите код из СМС отправленный на номер:\n".localizedSafe + "\(authorization.phone)"
        resendLabel.textAlignment = .center
        resentButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        codeField.becomeFirstResponder()
    }
    
    @IBAction func confirmButtonDidTap() {
        let accounts = authorization.accounts.filter { !$0.is_blocked }
        
        if let account = accounts.first, accounts.count == 1 {
            let phone = authorization.phone
            guard let code = codeField.text else { return }
            SVProgressHUD.show()
            API.default.checkSms(phone, code: Int(code) ?? 0, accountId: account.id, success: { [weak self] (response) in
                SVProgressHUD.dismiss()
                if let token = response?.token {
                    let user = User()
                    user.token = token
                    Database.default.add(user)
                    let mainController = Storyboard.Main.initialViewController!
                    mainController.modalPresentationStyle = .fullScreen
                    self?.present(mainController, animated: true, completion: nil)
                    
                    if Database.default.currentUser() != nil {
                        let fcmToken = UserDefaults.standard.string(forKey: "device_token") ?? ""
                        if(fcmToken != ""){
                            API.default.setDeviceToken(fcmToken)
                        }
                    }
                    
                } else {
                    self?.showAlert("Ошибка".localizedSafe, message: "Невозможно авторизоваться".localizedSafe)
                }
            }) { [weak self] (error, statusCode) in
                SVProgressHUD.dismiss()
                self?.showAlert("Ошибка".localizedSafe, message: "Невозможно авторизоваться".localizedSafe)
            }
            return
        }
        
        let alertController = UIAlertController(title: "Выберите аккаунт для входа".localizedSafe, message: nil, preferredStyle: .alert)
        for account in accounts {
            guard !account.is_blocked else { return }
            let action = UIAlertAction(title: account.company, style: .default) { [weak self] _ in
                guard let phone = self?.authorization.phone, let code = self?.codeField.text else { return }
                SVProgressHUD.show()
                API.default.checkSms(phone, code: Int(code) ?? 0, accountId: account.id, success: { [weak self] (response) in
                    SVProgressHUD.dismiss()
                    if let token = response?.token {
                        let user = User()
                        user.token = token
                        Database.default.add(user)
                        
                        if Database.default.currentUser() != nil {
                            let fcmToken = UserDefaults.standard.string(forKey: "device_token") ?? ""
                            if(fcmToken != ""){
                                API.default.setDeviceToken(fcmToken)
                            }
                        }
                        
                        
                        let mainController = Storyboard.Main.initialViewController!
                        mainController.modalPresentationStyle = .fullScreen
                        self?.present(mainController, animated: true, completion: nil)
                    } else {
                        self?.showAlert("Ошибка".localizedSafe, message: "Невозможно авторизоваться".localizedSafe)
                    }
                    }, failure: { [weak self] (error, statusCode) in
                        SVProgressHUD.dismiss()
                        self?.showAlert("Ошибка".localizedSafe, message: "Невозможно авторизоваться".localizedSafe)
                })
            }
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Отмена".localizedSafe, style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func codeFieldDidChange(_ textField: UITextField) {
        guard var text = textField.text else { return }
        resendButton.isHidden = !text.isEmpty || !isCanResend
        confirmButton.isEnabled = text.count >= 4
        confirmButton.isHidden = text.isEmpty
        resendLabel.isHidden = !text.isEmpty
        if text.count > 4 {
            text.removeLast()
            textField.text = text
        }
    }
    
    var isCanResend: Bool = false
    
    var totalTime = 60
    var countdownTimer: Timer!
    
    func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        resendLabel.text = "Повторно запросить код можно через ".localizedSafe + "\(timeFormatted(totalTime))" + " сек.".localizedSafe
        
        if totalTime != 0 {
            totalTime -= 1
        } else {
            endTimer()
        }
    }
    
    func endTimer() {
        countdownTimer.invalidate()
        self.isCanResend = true
        self.codeFieldDidChange(self.codeField)
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds// % 60
        //let minutes: Int = (totalSeconds / 60) % 60
        //     let hours: Int = totalSeconds / 3600
        return String(format: "%02d", seconds)
    }
    
    @IBAction func resentButton() {
        //let startTime = Int(Date().timeIntervalSince1970)
        //let endTime = startTime + 60
        resendButton.isHidden = true
        resendLabel.isHidden = false
        self.resendLabel.text = "Повторно запросить код можно через 60 сек.".localizedSafe
        isCanResend = false
        
        if !isFirst {
            API.default.getSms(phone, success: { (response) in
                if let response = response {
                    self.authorization = response
                }
            }) { (error, statusCode) in
                print(error)
            }
        }
        isFirst = false
        
        startTimer()
        
        //        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [unowned self] (timer) in
        //            let currentTime = Int(Date().timeIntervalSince1970)
        //            if endTime > currentTime {
        //                self.resendLabel.text = "Повторно запросить код можно через ".localizedSafe + "\(endTime - currentTime)" + " сек.".localizedSafe
        //            } else {
        //                timer.invalidate()
        //                self.isCanResend = true
        //                self.codeFieldDidChange(self.codeField)
        //            }
        //        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
