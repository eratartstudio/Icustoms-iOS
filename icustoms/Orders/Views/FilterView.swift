//
//  FilterView.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 08/04/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit

enum PaidFilterType: Int {
    case all
    case notPaid
    case paid
    
    static let array: [PaidFilterType] = [.all, .notPaid, .paid]
}

enum StatusOrder: String {
    case all = "Все"
    case first = "Создан"
    case second = "В работе (Аналитика)"
    case third = "В работе (Декларирование)"
    case four = "ДТ присвоен номер"
    case five = "ДТ на проверке"
    case six = "ДТ выпуск"
    case seven = "ДТ осуществляется досмотр"
    case eight = "Условный выпуск"
    case nine = "Завершен"
    
    static let array: [StatusOrder] = [.all, .first, .second, .third, .four, .five, .six, .seven, .eight, .nine]
    
    static func number(from status: StatusOrder) -> Int {
        switch status {
        case .first: return 1
        case .second: return 2
        case .third: return 3
        case .four: return 4
        case .five: return 5
        case .six: return 6
        case .seven: return 7
        case .eight: return 8
        case .nine: return 11
        default:
            return 0
        }
    }
}

protocol FilterViewDelegate: class {
    func filterView(_ view: FilterView, didSave filter: FilterOrder)
}

class FilterView: UIView {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var leftSelectedConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedView: UIView!
    
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var notPaidButton: UIButton!
    @IBOutlet weak var paidButton: UIButton!
    
    @IBOutlet weak var statusField: UITextField!
    @IBOutlet weak var dateFromField: UITextField!
    @IBOutlet weak var dateToField: UITextField!
    
    private var statusPicker: UIPickerView!
    private var fromDatePicker: UIDatePicker!
    private var toDatePicker: UIDatePicker!
    
    weak var delegate: FilterViewDelegate?
    
    var filter: FilterOrder!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if filter == nil {
            filter = FilterOrder()
        }
        
        createStatusPicker()
        createDatesPickers()
        
        borderView.layer.cornerRadius = 6
        borderView.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        borderView.layer.borderWidth = 1
    }
    
    @IBAction func selectPaidTypeAction(_ sender: UIButton) {
        guard let type = PaidFilterType(rawValue: sender.tag) else { return }
        filter.paidType = type
        leftSelectedConstraint.constant = sender.frame.minX + 4
        disableButtons()
        UIView.animate(withDuration: 0.3) {
            self.activeButton(sender)
            self.layoutIfNeeded()
        }
    }
    
    private func createStatusPicker() {
        statusPicker = UIPickerView()
        statusPicker.delegate = self
        statusPicker.dataSource = self
        statusField.inputView = statusPicker
        statusField.addDoneButtonOnKeyboard()
    }
    
    private func createDatesPickers() {
        fromDatePicker = UIDatePicker()
        fromDatePicker.addTarget(self, action: #selector(datePickerDidChange(_:)), for: .valueChanged)
        fromDatePicker.datePickerMode = .date
        dateFromField.inputView = fromDatePicker
        dateFromField.addDoneButtonOnKeyboard()
        
        toDatePicker = UIDatePicker()
        toDatePicker.addTarget(self, action: #selector(datePickerDidChange(_:)), for: .valueChanged)
        toDatePicker.datePickerMode = .date
        dateToField.inputView = toDatePicker
        dateToField.addDoneButtonOnKeyboard()
    }
    
    @objc private func datePickerDidChange(_ picker: UIDatePicker) {
        if picker == fromDatePicker {
            toDatePicker.minimumDate = picker.date
            dateFromField.text = "c ".localizedSafe + picker.date.string(with: "dd.MM.yyyy")
            filter.dateFrom = picker.date
        } else {
            dateToField.text = "до ".localizedSafe + picker.date.string(with: "dd.MM.yyyy")
            filter.dateTo = picker.date
        }
    }
 
    private func disableButtons() {
        allButton.setTitleColor(.white, for: .normal)
        notPaidButton.setTitleColor(.white, for: .normal)
        paidButton.setTitleColor(.white, for: .normal)
        
        allButton.alpha = 0.5
        notPaidButton.alpha = 0.5
        paidButton.alpha = 0.5
    }
    
    private func activeButton(_ button: UIButton) {
        button.alpha = 1
        button.setTitleColor(UIColor(red: 51/255, green: 0, blue: 153/255, alpha: 1), for: .normal)
    }
    
    @IBAction private func filterSaveAction() {
        delegate?.filterView(self, didSave: filter)
    }
}


extension FilterView: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
}

extension FilterView: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return StatusOrder.array.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return StatusOrder.array[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        statusField.text = StatusOrder.array[row].rawValue
        filter.status = StatusOrder.array[row]
    }
    
}
