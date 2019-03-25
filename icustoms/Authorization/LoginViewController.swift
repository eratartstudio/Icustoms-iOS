//
//  LoginViewController.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 22/03/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit
import country_flag
import PhoneNumberKit
import SVProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var phoneField: PhoneNumberTextField!
    @IBOutlet weak var codePrivateField: UITextField!
    @IBOutlet weak var sendButton: Button!
    
    private var codePicker: UIPickerView!
    
    private var codes: [String] = []
    
    var authorization: AuthorizationResponse!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.shadowImage = UIImage()
        codes = Country.current.codes()
        createPicker()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        phoneField.becomeFirstResponder()
    }
    
    func createPicker() {
        codePicker = UIPickerView()
        codePicker.delegate = self
        codePicker.dataSource = self
        codePrivateField.inputView = codePicker
        codePrivateField.addDoneButtonOnKeyboard()
    }
    
    @IBAction func codeDidTap() {
//        codePrivateField.becomeFirstResponder()
    }
    
    @IBAction func phoneFieldDidChange(_ textField: UITextField) {
        sendButton.isEnabled = (textField.text?.count ?? 0) >= 5
    }
    
    @IBAction func sendButtonDidTap() {
        SVProgressHUD.show()
        API.default.getSms(phone()) { (response) in
            SVProgressHUD.dismiss()
            if let response = response {
                self.authorization = response
                self.performSegue(withIdentifier: "ShowCodeView", sender: self)
            } else {
                self.showAlert("Ошибка", message: "Невозможно авторизоваться")
            }
        }
    }
    
    private func phone() -> String {
        return "\(codeLabel.text ?? "")\(phoneField.text ?? "")"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCodeView" {
            let vc = segue.destination as! ConfirmCodeViewController
            vc.authorization = authorization
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}

extension LoginViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return codes.count
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return codes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        codeLabel.text = codes[row]
    }
    
}