//
//  BalanceViewController.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 27/03/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit
import SVProgressHUD

struct Transaction {
    let price: Double
    let description: String
}

class BalanceViewController: UIViewController {
    
    var data: [(timestamp: Int, transactions: [BalanceTransaction])] = []
 
    var counts: [String: Double] = [:]
    
    var items: [BalanceTransaction] = []
    
    var filteredItems: [BalanceTransaction] = []
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var countFirstLabel: UILabel!
    @IBOutlet weak var countLastLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchField: UITextField!
    
    @IBOutlet weak var searchRightConstraint: NSLayoutConstraint!
    
    let initialRightConstraint: CGFloat = 15
    let activeRightConstraint: CGFloat = 85
    
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    var isSearchActive: Bool {
        return searchField.text?.isEmpty == false || searchField.isFirstResponder
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    @objc func update() {
        API.default.balance(success: { [weak self] (items) in
            self?.items = items
            self?.updateData()
            self?.refreshControl.endRefreshing()
            self?.tableView.reloadData()
        }) { [weak self] (error, statusCode) in
            self?.refreshControl.endRefreshing()
            self?.showAlert("Ошибка".localizedSafe, message: "Невозможно загрузить баланс".localizedSafe)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(update), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        SVProgressHUD.show()
        API.default.balance(success: { [weak self] (items) in
            SVProgressHUD.dismiss()
            self?.items = items
            self?.updateData()
            self?.tableView.reloadData()
        }) { [weak self] (error, statusCode) in
            SVProgressHUD.dismiss()
            self?.showAlert("Ошибка".localizedSafe, message: "Невозможно загрузить баланс".localizedSafe)
        }
        
        searchField.clearButtonMode = .whileEditing
        searchField.delegate = self
        
        tableView.keyboardDismissMode = .interactive
        
        updateCurrentValue()
    }
    
    func updateData() {
        if isSearchActive {
            data = filteredItems.group { $0.timestamp }.map { (timestamp: $0.key, transactions: $0.value) }.sorted { $0.timestamp > $1.timestamp }
        } else {
            data = items.group { $0.timestamp }.map { (timestamp: $0.key, transactions: $0.value) }.sorted { $0.timestamp > $1.timestamp }
        }
    
        counts = [:]
        for value in data {
            let time = TimeInterval(value.timestamp)
            let month = time.month()
            var count: Double = 0
            
            value.transactions.forEach { count += $0.amount }
            if let last = counts[month] {
                counts[month] = last + count
            } else {
                counts[month] = count
            }
        }
        tableView.reloadData()
        updateCurrentValue()
    }
    
    func showInvoice(_ invoiceId: Int) {
        SVProgressHUD.show()
        API.default.invoiceFile(invoiceId, success: { [weak self] (data) in
            print("SUCCESS")
            let controller = InvoiceViewController.controller()
            controller.data = data
            self?.navigationController?.isNavigationBarHidden = false
            self?.push(controller, animated: true)
        }) { [weak self] (error, statusCode) in
            print(error)
            SVProgressHUD.dismiss()
            self?.showAlert("Ошибка".localizedSafe, message: "Невозможно загрузить файл".localizedSafe)
        }
    }
}

extension BalanceViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        let label = UILabel(frame: CGRect(x: 10, y: 15, width: UIScreen.main.bounds.width, height: 30))
        label.font = UIFont.boldSystemFont(ofSize: 25.0)
        
        let date = Date(timeIntervalSince1970: Double(data[section].timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru".localizedSafe)
        dateFormatter.dateFormat = "dd MMMM"
        label.text = dateFormatter.string(from: date)
        
        v.addSubview(label)
        
        return v
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(TransactionTableCell.self, for: indexPath)
        cell.transaction = data[indexPath.section].transactions[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let transaction = data[indexPath.section].transactions[indexPath.row]
        let controller = BalanceDetailViewController.storyboardInstance()
        controller.transaction = transaction
        controller.present(from: self)
    }
    
    func updateCurrentValue() {
        guard let indexPath = tableView.indexPathsForVisibleRows?.first else {
            countFirstLabel.text = nil
            countLastLabel.text = nil
            monthLabel.text = nil
            return
        }
        let time = TimeInterval(data[indexPath.section].timestamp)
        let month = time.month()
        guard let count = counts[month] else { return }
        monthLabel.text = month
        let present = count.presentable()
        countLastLabel.text = "." + present.last + " ₽"
        if count > 0 {
            countFirstLabel.text = "+" + present.first
        } else {
            countFirstLabel.text = present.first
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCurrentValue()
        if searchField.isFirstResponder {
            searchField.resignFirstResponder()
        }
    }
    
}

extension BalanceViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        searchRightConstraint.constant = activeRightConstraint
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        updateData()
    }
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        search(textField.text)
    }
    
    func search(_ text: String?) {
        guard let text = text, !text.isEmpty else {
            filteredItems = []
            updateData()
            return
        }
        DispatchQueue.global().async {
            self.filteredItems = self.items.filter { $0.description.lowercased().contains(text.lowercased()) }
            DispatchQueue.main.async {
                self.updateData()
            }
        }
    }
    
    @IBAction func cancelSearch() {
        searchField.text = nil
        searchField.resignFirstResponder()
        filteredItems = []
        updateData()
        searchRightConstraint.constant = initialRightConstraint
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if searchField.text?.isEmpty == true {
            filteredItems = []
        }
        updateData()
    }
    
}

class TransactionTableCell: UITableViewCell {
    
    @IBOutlet weak var priceFirstLabel: UILabel!
    @IBOutlet weak var priceLastLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var transaction: BalanceTransaction? {
        didSet {
            update()
        }
    }
    
    private func update() {
        guard let transaction = transaction else { return }
        let price = transaction.amount.presentable()
        priceLastLabel.text = "." + price.last + " ₽"
        if transaction.transactionType == .substract {
            priceFirstLabel.text = price.first
            priceFirstLabel.textColor = .black
            priceLastLabel.textColor = .lightGray
        } else {
            priceFirstLabel.text = "+" + price.first
            priceFirstLabel.textColor = UIColor(red: 107/255, green: 187/255, blue: 92/255, alpha: 1) // 145 203 132
            priceLastLabel.textColor = UIColor(red: 145/255, green: 203/255, blue: 132/255, alpha: 1)
        }
        descriptionLabel.text = transaction.description
    }
    
}

extension Double {
    func presentable() -> (first: String, last: String) {
        let int = Int(self)
        var last = ""
        var s = Int(ceil(100 * (self - Double(int))))
        if s < 0 {
            s = -s
        }
        if s < 10 {
            last = "0\(s)"
        } else {
            last = "\(s)"
        }
        return (first: int.formattedWithSeparator, last: last)
    }
}

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.numberStyle = .decimal
        return formatter
    }()
}

extension BinaryInteger {
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}

extension TimeInterval {
    
    func month() -> String {
        let months = [
            "Январь".localizedSafe,
            "Февраль".localizedSafe,
            "Март".localizedSafe,
            "Апрель".localizedSafe,
            "Май".localizedSafe,
            "Июнь".localizedSafe,
            "Июль".localizedSafe,
            "Август".localizedSafe,
            "Сентябрь".localizedSafe,
            "Октябрь".localizedSafe,
            "Ноябрь".localizedSafe,
            "Декабрь".localizedSafe
        ]
        let date = Date(timeIntervalSince1970: self)
        let int = Calendar.current.component(.month, from: date)
        return months[int - 1]
    }
}
