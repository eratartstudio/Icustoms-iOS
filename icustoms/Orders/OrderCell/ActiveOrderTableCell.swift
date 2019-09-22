//
//  File.swift
//  icustoms
//
//  Created by Danik's MacBook on 22/09/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit
import SVProgressHUD
import Cosmos
import UICircularProgressRing

class ActiveOrderTableCell: UITableViewCell {
    
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var paidLabel: UILabel!
    @IBOutlet weak var analyticsCircleContainerView: UIView!
    @IBOutlet weak var analyticsCircleView: UICircularProgressRing!
    
    @IBOutlet weak var releaseCircleContainerView: UIView!
    @IBOutlet weak var releaseView: UIView!
    @IBOutlet weak var releaseCircleView: UICircularProgressRing!
    
    @IBOutlet weak var declarationCircleWhiteView: UIView!
    
    @IBOutlet weak var analyticsCompleted: UIImageView!
    @IBOutlet weak var declarationCompleted: UIImageView!
    @IBOutlet weak var releaseCompleted: UIImageView!
    
    @IBOutlet weak var declarationView: UIView!
    @IBOutlet weak var endedView: UIView!
    @IBOutlet weak var endedCompleted: UIImageView!
    
    @IBOutlet weak var analyticLabel: UILabel!
    @IBOutlet weak var declarationLabel: UILabel!
    @IBOutlet weak var releaseLabel: UILabel!
    @IBOutlet weak var endedLabel: UILabel!
    
    @IBOutlet weak var firstProgressView: UIView!
    @IBOutlet weak var secondProgressView: UIView!
    
    let activeColor: UIColor = UIColor(red: 111/255, green: 184/255, blue: 98/255, alpha: 1)
    let inactiveColor: UIColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    
    //var locale: Localization!
    
    var order: Order? {
        didSet {
            updateContent()
        }
    }
    
    private func updateContent() {
        guard let order = order else { return }
        
        orderIdLabel.text = order.orderId
        statusLabel.text = order.status?.name.localizedSafe
        
        if let percentPaid = order.invoice?.percentPaid, percentPaid > 0 {
            if percentPaid >= 100 {
                paidLabel.backgroundColor = activeColor//UIColor(red: 0, green: 198/255, blue: 1, alpha: 0)
                paidLabel.text = "оплачен".localizedSafe + "\(Int(percentPaid))%"
                
            } else if percentPaid > 0 {
                paidLabel.backgroundColor = UIColor(red: 1, green: 198/255, blue: 0, alpha: 1)
                paidLabel.text = "оплачен".localizedSafe + "\(Int(percentPaid))%"
            } else {
                paidLabel.backgroundColor = UIColor(red: 1, green: 198/255, blue: 0, alpha: 1)
            }
            //paidLabel.text = String(format: locale.get(.paid_percent), Int(percentPaid))
        } else {
            if(order.isPaid) {
                paidLabel.backgroundColor = activeColor
                paidLabel.text = "оплачен".localizedSafe + "100%"
            } else {
                paidLabel.backgroundColor = UIColor(red: 253/255, green: 123/255, blue: 32/255, alpha: 1)
                paidLabel.text = "Не оплачен".localizedSafe
            }
        }
        paidLabel.isHidden = false
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru".localizedSafe)
        dateFormatter.dateFormat = "dd MMMM yyyy"
        let date = Date.from(string: order.createdAt, format: "yyyy-MM-dd'T'HH:mm:ssZZZ")
        dateLabel.text = dateFormatter.string(from: date).uppercased()
        prepareStatus(order.status?.id ?? 0)
    }
    
    func chekNetarif() {
        guard let order = order else { return }
        if order.checkNetarif == true {
            paidLabel.isHidden = true
            declarationView.isHidden = true
            declarationLabel.isHidden = true
            releaseView.isHidden = true
            releaseLabel.isHidden = true
        } else if order.checkNetarif == false {
            paidLabel.isHidden = false
            declarationView.isHidden = false
            releaseView.isHidden = false
        }
    }
    
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
            
            analyticLabel.isHidden = false
            declarationLabel.isHidden = false
            releaseLabel.isHidden = false
            endedLabel.isHidden = false
            
            firstProgressView.isHidden = true
            secondProgressView.isHidden = true
            
            declarationCircleWhiteView.isHidden = true
            
            chekNetarif()
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
            
            analyticLabel.textColor = inactiveColor
            declarationLabel.textColor = inactiveColor
            releaseLabel.textColor = inactiveColor
            endedLabel.textColor = inactiveColor
            
            analyticLabel.isHidden = true
            declarationLabel.isHidden = false
            releaseLabel.isHidden = false
            endedLabel.isHidden = false
            
            firstProgressView.isHidden = true
            secondProgressView.isHidden = true
            
            declarationCircleWhiteView.isHidden = true
            
            chekNetarif()
        case 3:
            analyticsCompleted.isHidden = false
            declarationCompleted.isHidden = true
            releaseCompleted.isHidden = true
            releaseCircleContainerView.isHidden = true
            endedCompleted.isHidden = true
            endedView.backgroundColor = inactiveColor
            declarationView.backgroundColor = activeColor
            
            analyticLabel.textColor = activeColor
            declarationLabel.textColor = inactiveColor
            releaseLabel.textColor = inactiveColor
            endedLabel.textColor = inactiveColor
            
            analyticLabel.isHidden = false
            declarationLabel.isHidden = true
            releaseLabel.isHidden = false
            endedLabel.isHidden = false
            
            firstProgressView.isHidden = false
            secondProgressView.isHidden = true
            
            declarationCircleWhiteView.isHidden = false
            
            chekNetarif()
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
            releaseLabel.textColor = inactiveColor
            endedLabel.textColor = inactiveColor
            
            analyticLabel.isHidden = false
            declarationLabel.isHidden = false
            releaseLabel.isHidden = true
            endedLabel.isHidden = false
            
            firstProgressView.isHidden = false
            secondProgressView.isHidden = false
            
            declarationCircleWhiteView.isHidden = true
            
            chekNetarif()
        case 8:
            analyticsCompleted.isHidden = false
            declarationCompleted.isHidden = false
            releaseCompleted.isHidden = false
            endedCompleted.isHidden = true
            endedView.backgroundColor = activeColor
            
            analyticLabel.textColor = activeColor
            declarationLabel.textColor = activeColor
            releaseLabel.textColor = activeColor
            endedLabel.textColor = inactiveColor
            
            analyticLabel.isHidden = false
            declarationLabel.isHidden = false
            releaseLabel.isHidden = false
            endedLabel.isHidden = true
            
            firstProgressView.isHidden = false
            secondProgressView.isHidden = false
            
            declarationCircleWhiteView.isHidden = true
            
            chekNetarif()
        case 9:
            analyticsCompleted.isHidden = false
            declarationCompleted.isHidden = false
            releaseCompleted.isHidden = false
            endedView.isHidden = false
            endedCompleted.isHidden = false
            
            analyticLabel.textColor = activeColor
            declarationLabel.textColor = activeColor
            releaseLabel.textColor = activeColor
            endedLabel.textColor = activeColor
            
            analyticLabel.text = analyticLabel.text
            declarationLabel.text = declarationLabel.text
            releaseLabel.text = releaseLabel.text
            endedLabel.text = endedLabel.text
            
            firstProgressView.isHidden = false
            secondProgressView.isHidden = false
            releaseCircleView.isHidden = false
            
            chekNetarif()
        case 11:
            analyticsCompleted.isHidden = false
            declarationCompleted.isHidden = false
            releaseCompleted.isHidden = false
            endedView.isHidden = false
            endedCompleted.isHidden = false
            
            analyticLabel.textColor = activeColor
            declarationLabel.textColor = activeColor
            releaseLabel.textColor = activeColor
            endedLabel.textColor = activeColor
            
            analyticLabel.text = analyticLabel.text
            declarationLabel.text = declarationLabel.text
            releaseLabel.text = releaseLabel.text
            endedLabel.text = endedLabel.text
            
            firstProgressView.isHidden = false
            secondProgressView.isHidden = false
            releaseCircleView.isHidden = false
            
            chekNetarif()
        default:
            break
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        analyticsCircleView.minValue = 0
        analyticsCircleView.maxValue = 100
        analyticsCircleView.innerCapStyle = .butt
        analyticsCircleView.style = .inside
        
        releaseCircleView.minValue = 0
        releaseCircleView.maxValue = 100
        releaseCircleView.innerCapStyle = .butt
        releaseCircleView.style = .inside
    }
}
