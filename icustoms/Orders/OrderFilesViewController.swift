//
//  OrderFilesViewController.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 04/04/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit
import SVProgressHUD

class OrderFilesViewController: UIViewController {
    
    var order: Order!
    var files: [File] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.isHidden = true
        SVProgressHUD.show()
        API.default.files(order.id, { [weak self] (files) in
            SVProgressHUD.dismiss()
            self?.files = files
            self?.tableView.isHidden = false
            self?.tableView.reloadData()
        }) { [weak self] (error, statusCode) in
            SVProgressHUD.dismiss()
            self?.showAlert("Ошибка", message: "Невозможно загрузить файлы")
        }
    }
    
}

extension OrderFilesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(FileTableCell.self, for: indexPath)
        cell.file = files[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = OrderFileDetailViewController.controller()
        controller.file = files[indexPath.row]
        controller.currentIndex = indexPath.row
        controller.filesCount = files.count
        present(controller, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

class FileTableCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    var file: File? {
        didSet {
            updateContent()
        }
    }
    
    private func updateContent() {
        guard let file = file else { return }
        nameLabel.text = file.number
        descriptionLabel.text = file.name
        typeLabel.text = file.mimeType
    }
    
}