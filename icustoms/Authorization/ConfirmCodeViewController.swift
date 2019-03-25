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
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var resendButton: Button!
    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var confirmButton: Button!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionLabel.text = "Введите код из СМС отправленный на номер:\n\(authorization.phone)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        codeField.becomeFirstResponder()
    }
    
    @IBAction func confirmButtonDidTap() {
        let accounts = authorization.accounts.filter { !$0.is_blocked }
        
        let alertController = UIAlertController(title: "Выберите аккаунт для входа", message: nil, preferredStyle: .alert)
        for account in accounts {
            guard !account.is_blocked else { return }
            let action = UIAlertAction(title: account.company, style: .default) { [weak self] _ in
                guard let phone = self?.authorization.phone, let code = self?.codeField.text else { return }
                SVProgressHUD.show()
                API.default.checkSms(phone, code: Int(code) ?? 0, accountId: account.id, { (response) in
                    SVProgressHUD.dismiss()
                    if let token = response?.token {
                        let user = User()
                        user.token = token
                        Database.default.add(user)
                        let mainController = Storyboard.Main.initialViewController!
                        self?.present(mainController, animated: true, completion: nil)
                    } else {
                        self?.showAlert("Ошибка", message: "Невозможно авторизоваться")
                    }
                })
            }
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func codeFieldDidChange(_ textField: UITextField) {
        guard var text = textField.text else { return }
        resendButton.isHidden = !text.isEmpty
        confirmButton.isEnabled = text.count >= 4
        if text.count > 4 {
            text.removeLast()
            textField.text = text
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}
