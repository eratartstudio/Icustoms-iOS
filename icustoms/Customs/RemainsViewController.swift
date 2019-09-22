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
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
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
