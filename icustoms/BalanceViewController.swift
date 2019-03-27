//
//  BalanceViewController.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 27/03/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit

struct Transaction {
    let price: Double
    let description: String
}

class BalanceViewController: UIViewController {
    
    var data: [(timestamp: Int, transactions: [Transaction])] = []
 
    var counts: [String: Double] = [:]
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var countFirstLabel: UILabel!
    @IBOutlet weak var countLastLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        data.append((timestamp: 1549152000, transactions: [Transaction(price: -11580.29, description: "Услуга по счету 2"), Transaction(price: -3420.29, description: "Услуга по счету 2"), Transaction(price: -11580.29, description: "Услуга по счету 2"), Transaction(price: -3420.29, description: "Услуга по счету 2")]))
        data.append((timestamp: 1549065600, transactions: [Transaction(price: 9500.30, description: "Оплата по договору 2"), Transaction(price: 8500.30, description: "Оплата по договору 1"), Transaction(price: 9500.30, description: "Оплата по договору 2"), Transaction(price: 8500.30, description: "Оплата по договору 1")]))
        data.append((timestamp: 1548720000, transactions: [Transaction(price: 1000.00, description: "Оплата по договору"), Transaction(price: -11580.29, description: "Услуга"), Transaction(price: 1000.00, description: "Оплата по договору"), Transaction(price: -11580.29, description: "Услуга")]))
        data.append((timestamp: 1548547200, transactions: [Transaction(price: 21020.12, description: "Оплата"), Transaction(price: 100.01, description: "Оплата"), Transaction(price: 21020.12, description: "Оплата"), Transaction(price: 100.01, description: "Оплата")]))
        
        for value in data {
            let time = TimeInterval(value.timestamp)
            let month = time.month()
            var count: Double = 0
            value.transactions.forEach { count += $0.price }
            if let last = counts[month] {
                counts[month] = last + count
            } else {
                counts[month] = count
            }
        }
        tableView.reloadData()
        updateCurrentValue()
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
        guard let indexPath = tableView.indexPathsForVisibleRows?.first else { return }
        let time = TimeInterval(data[indexPath.section].timestamp)
        let month = time.month()
        guard let count = counts[month] else { return }
        monthLabel.text = month
        let present = count.presentable()
        countLastLabel.text = "." + present.last + " P"
        if count > 0 {
            countFirstLabel.text = "+" + present.first
        } else {
            countFirstLabel.text = present.first
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCurrentValue()
    }
    
}

class TransactionTableCell: UITableViewCell {
    
    @IBOutlet weak var priceFirstLabel: UILabel!
    @IBOutlet weak var priceLastLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var transaction: Transaction? {
        didSet {
            update()
        }
    }
    
    private func update() {
        guard let transaction = transaction else { return }
        let price = transaction.price.presentable()
        priceLastLabel.text = "." + price.last + " P"
        if transaction.price < 0 {
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
        let months = ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
        let date = Date(timeIntervalSince1970: self)
        let int = Calendar.current.component(.month, from: date)
        return months[int - 1]
    }
    
}
