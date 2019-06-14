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
    var local: Localization!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        local = Localization.current()
        confirmButton.isHidden = true
        
        descriptionLabel.text = local.get(.enter_sms_code) + "\n\(authorization.phone)"
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
                    self?.present(mainController, animated: true, completion: nil)
                } else {
                    self?.showAlert(self?.local.get(.error), message: self?.local.get(.authorization_failed))
                }
            }) { [weak self] (error, statusCode) in
                SVProgressHUD.dismiss()
                self?.showAlert(self?.local.get(.error), message: self?.local.get(.authorization_failed))
            }
            return
        }
        
        let alertController = UIAlertController(title: local.get(.select_account_login), message: nil, preferredStyle: .alert)
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
                        let mainController = Storyboard.Main.initialViewController!
                        self?.present(mainController, animated: true, completion: nil)
                    } else {
                         self?.showAlert(self?.local.get(.error), message: self?.local.get(.authorization_failed))
                    }
                }, failure: { [weak self] (error, statusCode) in
                    SVProgressHUD.dismiss()
                    self?.showAlert(self?.local.get(.error), message: self?.local.get(.authorization_failed))
                })
            }
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: local.get(.cancel), style: .cancel, handler: nil))
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
    
    @IBAction func resentButton() {
        let startTime = Int(Date().timeIntervalSince1970)
        let endTime = startTime + 60
        resendButton.isHidden = true
        resendLabel.isHidden = false
        self.resendLabel.text = String(format: local.get(.you_can_request_code_again), 60)
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
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [unowned self] (timer) in
            let currentTime = Int(Date().timeIntervalSince1970)
            if endTime > currentTime {
                
                self.resendLabel.text = String(format: self.local.get(.you_can_request_code_again), endTime - currentTime)
            } else {
                timer.invalidate()
                self.isCanResend = true
                self.codeFieldDidChange(self.codeField)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}
