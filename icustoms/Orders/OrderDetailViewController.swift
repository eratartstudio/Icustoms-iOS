//
//  OrderDetailViewController.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 29/03/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit
import UICircularProgressRing
import SVProgressHUD

class OrderDetailViewController: UIViewController {
    
    @IBOutlet weak var orderNumberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var paidLabel: UILabel!
    @IBOutlet weak var invoiceNumberLabel: UILabel!
    @IBOutlet weak var deliveryNameLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var currencyRateLabel: UILabel!
    @IBOutlet weak var avansLabel: UILabel!
    @IBOutlet weak var tollLabel: UILabel!
    
    @IBOutlet weak var analyticsCircleContainerView: UIView!
    @IBOutlet weak var analyticsCircleView: UICircularProgressRing!
    
    @IBOutlet weak var releaseCircleContainerView: UIView!
    @IBOutlet weak var releaseCircleView: UICircularProgressRing!
    
    @IBOutlet weak var analyticsCompleted: UIImageView!
    @IBOutlet weak var declarationCompleted: UIImageView!
    @IBOutlet weak var releaseCompleted: UIImageView!
    @IBOutlet weak var endedCompleted: UIImageView!
    
    @IBOutlet weak var declarationView: UIView!
    @IBOutlet weak var endedView: UIView!
    
    @IBOutlet weak var analyticLabel: UILabel!
    @IBOutlet weak var declarationLabel: UILabel!
    @IBOutlet weak var releaseLabel: UILabel!
    @IBOutlet weak var endedLabel: UILabel!
    
    @IBOutlet weak var firstProgressView: UIView!
    @IBOutlet weak var secondProgressView: UIView!
    @IBOutlet weak var thirdProgressView: UIView!
    
    let activeColor: UIColor = UIColor(red: 111/255, green: 184/255, blue: 98/255, alpha: 1)
    let inactiveColor: UIColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    
    var order: Order!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        analyticsCircleView.minValue = 0
        analyticsCircleView.maxValue = 100
        analyticsCircleView.innerCapStyle = .butt
        analyticsCircleView.style = .inside
        
        releaseCircleView.minValue = 0
        releaseCircleView.maxValue = 100
        releaseCircleView.innerCapStyle = .butt
        releaseCircleView.style = .inside
        
        orderNumberLabel.text = order.orderId
        paidLabel.isHidden = order.isPaid
        dateLabel.text = Date.from(string: order.createdAt, format: "yyyy-MM-dd'T'HH:mm:ssZZZ").string(with: "dd MMMM yyyy").uppercased()
        prepareStatus(order.status?.id ?? 0)
        
        invoiceNumberLabel.text = order.invoiceNumber
        deliveryNameLabel.text = order.deliveryService
        currencyLabel.text = order.currency?.code
        currencyRateLabel.text = order.currency?.rate
        avansLabel.text = order.prepaid
        tollLabel.text = order.toll
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowFiles" {
            let vc = segue.destination as! OrderFilesViewController
            vc.order = order
        }
    }
    
    @IBAction func saveInvoice() {
//        SVProgressHUD.show()
        API.default.invoiceFile(order.id, success: {
            
        }) { (error, statusCode) in
            
        }
    }
    
}

extension OrderDetailViewController {
    
    
    func prepareStatus(_ status: Int) {
        switch status {
        case 1:
            analyticsCircleContainerView.isHidden = true
            releaseCircleContainerView.isHidden = true
            analyticsCompleted.isHidden = true
            declarationCompleted.isHidden = true
            releaseCompleted.isHidden = true
            endedCompleted.isHidden = true
            endedView.backgroundColor = inactiveColor
            declarationView.backgroundColor = inactiveColor
            
            analyticLabel.textColor = inactiveColor
            declarationLabel.textColor = inactiveColor
            releaseLabel.textColor = inactiveColor
            endedLabel.textColor = inactiveColor
            
            firstProgressView.isHidden = true
            secondProgressView.isHidden = true
            thirdProgressView.isHidden = true
        case 2:
            analyticsCircleContainerView.isHidden = false
            releaseCircleContainerView.isHidden = true
            analyticsCompleted.isHidden = true
            declarationCompleted.isHidden = true
            releaseCompleted.isHidden = true
            endedCompleted.isHidden = true
            let countReady = order?.countReady ?? 0
            let countGoods = order?.countGoods ?? 0
            analyticsCircleView.value = (CGFloat(countReady)/CGFloat(countGoods)) * 100
            endedView.backgroundColor = inactiveColor
            declarationView.backgroundColor = inactiveColor
            
            analyticLabel.textColor = activeColor
            declarationLabel.textColor = inactiveColor
            releaseLabel.textColor = inactiveColor
            endedLabel.textColor = inactiveColor
            
            analyticLabel.text = analyticLabel.text?.uppercased()
            
            firstProgressView.isHidden = true
            secondProgressView.isHidden = true
            thirdProgressView.isHidden = true
        case 3:
            analyticsCompleted.isHidden = false
            declarationCompleted.isHidden = true
            releaseCompleted.isHidden = true
            endedCompleted.isHidden = true
            releaseCircleContainerView.isHidden = true
            endedView.backgroundColor = inactiveColor
            declarationView.backgroundColor = activeColor
            
            analyticLabel.textColor = activeColor
            declarationLabel.textColor = activeColor
            releaseLabel.textColor = inactiveColor
            endedLabel.textColor = inactiveColor
            
            analyticLabel.text = analyticLabel.text?.uppercased()
            declarationLabel.text = declarationLabel.text?.uppercased()

            firstProgressView.isHidden = false
            secondProgressView.isHidden = true
            thirdProgressView.isHidden = true
        case 4, 5, 6, 7:
            analyticsCompleted.isHidden = false
            declarationCompleted.isHidden = false
            releaseCompleted.isHidden = true
            endedCompleted.isHidden = true
            releaseCircleContainerView.isHidden = false
            
            releaseCircleView.value = CGFloat(status - 4) * 25
            endedView.backgroundColor = inactiveColor
            
            analyticLabel.textColor = activeColor
            declarationLabel.textColor = activeColor
            releaseLabel.textColor = activeColor
            endedLabel.textColor = inactiveColor
            
            analyticLabel.text = analyticLabel.text?.uppercased()
            declarationLabel.text = declarationLabel.text?.uppercased()
            releaseLabel.text = releaseLabel.text?.uppercased()
            
            firstProgressView.isHidden = false
            secondProgressView.isHidden = false
            thirdProgressView.isHidden = true
        case 8:
            analyticsCompleted.isHidden = false
            declarationCompleted.isHidden = false
            releaseCompleted.isHidden = false
            endedCompleted.isHidden = true
            endedView.backgroundColor = activeColor
            
            analyticLabel.textColor = activeColor
            declarationLabel.textColor = activeColor
            releaseLabel.textColor = activeColor
            endedLabel.textColor = activeColor
            
            analyticLabel.text = analyticLabel.text?.uppercased()
            declarationLabel.text = declarationLabel.text?.uppercased()
            releaseLabel.text = releaseLabel.text?.uppercased()
            endedLabel.text = endedLabel.text?.uppercased()
            
            firstProgressView.isHidden = false
            secondProgressView.isHidden = false
            thirdProgressView.isHidden = false
        case 11:
            analyticsCompleted.isHidden = false
            declarationCompleted.isHidden = false
            releaseCompleted.isHidden = false
            endedCompleted.isHidden = false
            
            analyticLabel.textColor = activeColor
            declarationLabel.textColor = activeColor
            releaseLabel.textColor = activeColor
            endedLabel.textColor = activeColor
            
            analyticLabel.text = analyticLabel.text?.uppercased()
            declarationLabel.text = declarationLabel.text?.uppercased()
            releaseLabel.text = releaseLabel.text?.uppercased()
            endedLabel.text = endedLabel.text?.uppercased()
            
            firstProgressView.isHidden = false
            secondProgressView.isHidden = false
            thirdProgressView.isHidden = false
        default:
            break
        }
    }
    
}
