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
    
    var phone: String!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var resendButton: Button!
    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var confirmButton: Button!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionLabel.text = "Введите код из СМС отправленный на номер:\n\(phone!)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        codeField.becomeFirstResponder()
    }
    
    @IBAction func confirmButtonDidTap() {
        SVProgressHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            SVProgressHUD.dismiss()
            let accounts = ["OOO \"Электронимпортком\"", "ООО \"Компания\"", "Другой аккаунт"]
            let alertController = UIAlertController(title: "Выберите аккаунт для входа", message: nil, preferredStyle: .alert)
            for account in accounts {
                let action = UIAlertAction(title: account, style: .default) { [weak self] _ in
                    let mainController = Storyboard.Main.initialViewController!
                    self?.present(mainController, animated: true, completion: nil)
                }
                alertController.addAction(action)
            }
            
            alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
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
