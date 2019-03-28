//
//  ViewController.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 21/03/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit
import SVProgressHUD

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var orders: [Order] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.show()
        API.default.orders(success: { [weak self] (orders) in
            SVProgressHUD.dismiss()
            self?.orders = orders
            self?.tableView.reloadData()
        }) { [weak self] (error, statusCode) in
            SVProgressHUD.dismiss()
            self?.showAlert("Ошибка", message: "Невозможно загрузить заказы")
        }
    }


}


extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ActiveOrderTableCell.self, for: indexPath)
        cell.order = orders[indexPath.row]
        return cell
    }
    
}

import UICircularProgressRing

class ActiveOrderTableCell: UITableViewCell {
    
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var analyticsCircleView: UICircularProgressRing!
    
    var order: Order? {
        didSet {
            updateContent()
        }
    }
    
    private func updateContent() {
        guard let order = order else { return }
        
        orderIdLabel.text = order.orderId
        statusLabel.text = order.status?.name
        dateLabel.text = Date.from(string: order.createdAt, format: "yyyy-MM-dd'T'HH:mm:ssZZZ").string(with: "05 MMMM yyyy").uppercased()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        analyticsCircleView.minValue = 0
        analyticsCircleView.maxValue = 100
        analyticsCircleView.value = 30
    }
    
}
