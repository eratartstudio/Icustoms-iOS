//
//  RemainsViewController.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 25/03/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit
import SVProgressHUD

class RemainsViewController: UIViewController {
    
    var items: [Custom] = []
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(update), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        SVProgressHUD.show()
        API.default.customs(success: { [weak self] (customs) in
            SVProgressHUD.dismiss()
            self?.items = customs
            self?.tableView.reloadData()
        }) { [weak self] (error, statusCode) in
            SVProgressHUD.dismiss()
            self?.showAlert("Ошибка".localizedSafe, message: "Невозможно загрузить остатки".localizedSafe)
        }
    }
    
    @objc func update() {
        API.default.customs(success: { [weak self] (customs) in
            self?.refreshControl.endRefreshing()
            self?.items = customs
            self?.tableView.reloadData()
        }) { [weak self] (error, statusCode) in
            self?.refreshControl.endRefreshing()
            self?.showAlert("Ошибка".localizedSafe, message: "Невозможно загрузить остатки".localizedSafe)
        }
    }
}

extension RemainsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(RemainTableCell.self, for: indexPath)
        cell.custom = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = CustomDetailViewController.controller()
        controller.custom = items[indexPath.row]
        push(controller, animated: true)
    }
}

class RemainTableCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avansLabel: UILabel!
    @IBOutlet weak var tollLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var custom: Custom? {
        didSet {
            updateContent()
        }
    }
    
    private func updateContent() {
        guard let custom = custom else { return }
        titleLabel.text = custom.custom.name
        avansLabel.text = String(format: "%.2f", custom.totalAvans) + " Р"
        tollLabel.text = String(format: "%.2f", custom.totalToll) + " Р"
        dateLabel.text = Date.from(string: custom.actualDate, format: "yyyy-MM-dd'T'HH:mm:ssZZZ").string(with: "dd.MM.yyyy HH:mm")
    }
}
