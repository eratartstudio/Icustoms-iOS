//
//  File1.swift
//  icustoms
//
//  Created by Danik's MacBook on 22/09/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit
import SVProgressHUD
import Cosmos

class EndedOrderTableCell: UITableViewCell {
    
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var reviewContainerView: UIView!
    @IBOutlet weak var reviewTitleLabel: UILabel!
    
    private var reviewInputCosmosView: CosmosView!
    
    weak var controller: MainViewController?
    
    let reviewCompleteBackgroundColor: UIColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    let reviewBorderColor: UIColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        reviewContainerView.layer.cornerRadius = 4
        reviewContainerView.layer.borderWidth = 1
        reviewContainerView.layer.borderColor = reviewBorderColor.cgColor
        
        reviewInputCosmosView = CosmosView(frame: CGRect(x: 0, y: 140, width: 145, height: 25))
        reviewInputCosmosView.settings.starSize = 30
        reviewInputCosmosView.rating = 0
    }
    //var locale: Localization!
    var order: Order? {
        didSet {
            updateContent()
        }
    }
    
    private func updateContent() {
        guard let order = order else { return }
        
        orderIdLabel.text = order.orderId
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru".localizedSafe)
        dateFormatter.dateFormat = "dd MMMM yyyy"
        let date = Date.from(string: order.createdAt, format: "yyyy-MM-dd'T'HH:mm:ssZZZ")
        dateLabel.text = dateFormatter.string(from: date).uppercased()
        
        cosmosView.rating = order.reviewIsExist ? Double(order.review!.score) : 0
        reviewContainerView.backgroundColor = order.reviewIsExist ? reviewCompleteBackgroundColor : .white
        reviewTitleLabel.text = order.reviewIsExist ? "Оценка поставлена".localizedSafe : "Оцените заказ".localizedSafe
    }
    
    @IBAction func reviewClicked() {
        guard let order = order else { return }
        guard !order.reviewIsExist else { return }
        controller?.reviewClicked = true
        
        let alertController = UIAlertController(title: "Оцените заказ\n".localizedSafe + "\(order.orderId)", message: "Пожалуйста оцените работу\nменеджера при выполнении заказа.\nПомогите нам стать лучше!\n\n\n".localizedSafe, preferredStyle: .alert)
        
        reviewInputCosmosView.frame = CGRect(x: 0, y: 130, width: 180, height: 30)
        reviewInputCosmosView.center = CGPoint(x: alertController.view.center.x - 50, y: 145)
        alertController.view.addSubview(reviewInputCosmosView)
        
        alertController.addTextField { (textField) in
            textField.frame = CGRect(x: 15, y: 170, width: UIScreen.main.bounds.width - 135, height: 30)
            textField.placeholder = "Оставьте отзыв".localizedSafe
        }
        
        let sendAction = UIAlertAction(title: "Отправить".localizedSafe, style: .default) { _ in
            SVProgressHUD.show()
            let text = alertController.textFields?.first?.text ?? ""
            let score = Int(self.reviewInputCosmosView.rating)
            API.default.setReview(order.id, score: score, text: text, success: { (success) in
                SVProgressHUD.dismiss()
                var item = order
                item.review = OrderReview(text: text, score: score)
                item.reviewIsExist = true
                self.controller?.updateOrder(item, section: 1)
            }, failure: { (error, statusCode) in
                SVProgressHUD.dismiss()
                self.controller?.showAlert("Ошибка".localizedSafe, message: "Невозможно отправить отзыв".localizedSafe)
            })
        }
        
        let cancelAction = UIAlertAction(title: "Отмена".localizedSafe, style: .default, handler: nil)
        alertController.addAction(sendAction)
        alertController.addAction(cancelAction)
        controller?.present(alertController, animated: true, completion: nil)
    }
}
