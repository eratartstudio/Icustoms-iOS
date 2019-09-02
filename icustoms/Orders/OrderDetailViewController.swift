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
import WebKit
import SafariServices
import Toast_Swift

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
    
    @IBOutlet weak var declarationView: UICircularProgressRing!
    @IBOutlet weak var endedView: UIView!
    
    @IBOutlet weak var analyticLabel: UILabel!
    @IBOutlet weak var declarationLabel: UILabel!
    @IBOutlet weak var releaseLabel: UILabel!
    @IBOutlet weak var endedLabel: UILabel!
    
    @IBOutlet weak var analyticDate: UILabel!
    @IBOutlet weak var declarationDate: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var endedDate: UILabel!
    
    @IBOutlet weak var analyticCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var declarationCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var releaseCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var endedCenterConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var firstProgressView: UIView!
    @IBOutlet weak var secondProgressView: UIView!
    @IBOutlet weak var thirdProgressView: UIView!
    
    let activeColor: UIColor = UIColor(red: 111/255, green: 184/255, blue: 98/255, alpha: 1)
    let inactiveColor: UIColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    
    var order: Order!
    var statusHistories: StatusHistories!
    
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
        
        //        paidLabel.isHidden = order.isPaid
        //        order.invoice
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
        
        let date = Date.from(string: order.createdAt, format: "yyyy-MM-dd'T'HH:mm:ssZZZ")
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru".localizedSafe)
        dateFormatter.dateFormat = "dd MMMM yyyy"
        dateLabel.text = dateFormatter.string(from: date).uppercased()
        prepareStatus(order.status?.id ?? 0)
        
        
        var i = 0
        let size = order.statusHistories?.count ?? 0
        
        analyticDate.isHidden = true
        declarationDate.isHidden = true
        releaseDate.isHidden = true
        endedDate.isHidden = true
        
        if(size != 0) {
            order.statusHistories?.forEach{ history in
                switch i {
                case 0 :
                    analyticDate.isHidden = false
                    let date = Date.from(string: history?.date ?? "", format: "yyyy-MM-dd'T'HH:mm:ssZZZ")
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "ru".localizedSafe)
                    dateFormatter.dateFormat = "dd MMMM yyyy HH:mm"
                    analyticDate.text = dateFormatter.string(from: date)
                    i = i + 1
                case 1:
                    declarationDate.isHidden = false
                    let date = Date.from(string: history?.date ?? "", format: "yyyy-MM-dd'T'HH:mm:ssZZZ")
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "ru".localizedSafe)
                    dateFormatter.dateFormat = "dd MMMM yyyy HH:mm"
                    declarationDate.text = dateFormatter.string(from: date)
                    
                    declarationDate.isHidden = (declarationView.backgroundColor == inactiveColor) ? true : false
                    
                    i = i + 1
                case 2:
                    releaseDate.isHidden = false
                    let date = Date.from(string: history?.date ?? "", format: "yyyy-MM-dd'T'HH:mm:ssZZZ")
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "ru".localizedSafe)
                    dateFormatter.dateFormat = "dd MMMM yyyy HH:mm"
                    releaseDate.text = dateFormatter.string(from: date)
                    i = i + 1
                case 3:
                    endedDate.isHidden = false
                    let date = Date.from(string: history?.date ?? "", format: "yyyy-MM-dd'T'HH:mm:ssZZZ")
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "ru".localizedSafe)
                    dateFormatter.dateFormat = "dd MMMM yyyy HH:mm"
                    endedDate.text = dateFormatter.string(from: date)
                    i = i + 1
                default:
                    analyticDate.isHidden = true
                    declarationDate.isHidden = true
                    releaseDate.isHidden = true
                    endedDate.isHidden = true
                }
            }
        }
        
        analyticCenterConstraint.constant = analyticDate.isHidden ? 0 : -8
        declarationCenterConstraint.constant = declarationDate.isHidden ? 0 : -8
        releaseCenterConstraint.constant = releaseDate.isHidden ? 0 : -8
        endedCenterConstraint.constant = endedDate.isHidden ? 0 : -8
        
        invoiceNumberLabel.text = order.invoiceNumber.isEmpty ? "-" : order.invoiceNumber
        deliveryNameLabel.text = order.deliveryService
        currencyLabel.text = order.currency?.code
        currencyRateLabel.text = order.currency?.rate
        
        switch (Locale.current.languageCode) {
            case "ru":
                if(order.currency?.code == "RUB"){
                    avansLabel.text = order.prepaid.isEmpty ? "-" : order.prepaid
                    tollLabel.text = order.toll.isEmpty ? "-" : order.toll
                } else {
                    if(order.currency?.rate != nil) {
                        let avans = Float(order.prepaid.isEmpty ? "0" : order.prepaid) ?? 0
                        let toll = Float(order.toll.isEmpty ? "0" : order.toll) ?? 0
                        let rate = Float(order.currency!.rate!.isEmpty ? "0" : order.currency!.rate!) ?? 0
                        
                        avansLabel.text = avans == 0 ? "-" : String(avans*rate)
                        tollLabel.text = toll == 0 ? "-" : String(toll*rate)
                    }
                }
            default:
                avansLabel.text = order.prepaid.isEmpty ? "-" : order.prepaid
                tollLabel.text = order.toll.isEmpty ? "-" : order.toll
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowFiles" {
            let vc = segue.destination as! OrderFilesViewController
            vc.order = order
        }
    }
    
    @IBAction func copyNameOrder() {
        UIPasteboard.general.string = order.orderId
        view.makeToast("Номер заказа скопирован!".localizedSafe)
    }
    
    @IBAction func openLinkInvoice() {
        guard let url = URL(string: order!.trackingLink) else {
            self.showAlert("Ошибка".localizedSafe, message: "Файла не существует".localizedSafe)
            return
        }
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
    
    @IBAction func saveInvoice() {
        guard let invoiceId = order.invoice?.id else {
            self.showAlert("Ошибка".localizedSafe, message: "Файла не существует".localizedSafe)
            return
        }
        SVProgressHUD.show()
        API.default.invoiceFile(invoiceId, success: { [weak self] (data) in
            print("SUCCESS")
            let controller = InvoiceViewController.controller()
            controller.data = data
            self?.push(controller, animated: true)
        }) { [weak self] (error, statusCode) in
            print(error)
            SVProgressHUD.dismiss()
            self?.showAlert("Ошибка".localizedSafe, message: "Невозможно загрузить файл".localizedSafe)
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
            declarationLabel.textColor = declarationView.backgroundColor
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
            declarationView.backgroundColor = .white
            declarationView.outerRingColor = activeColor
            
            analyticLabel.textColor = activeColor
            declarationLabel.textColor = activeColor
            releaseLabel.textColor = inactiveColor
            endedLabel.textColor = inactiveColor
            
            analyticLabel.text = analyticLabel.text
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
            
            analyticLabel.text = analyticLabel.text
            declarationLabel.text = declarationLabel.text
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
            
            analyticLabel.text = analyticLabel.text
            declarationLabel.text = declarationLabel.text
            releaseLabel.text = releaseLabel.text
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
            
            analyticLabel.text = analyticLabel.text
            declarationLabel.text = declarationLabel.text
            releaseLabel.text = releaseLabel.text
            endedLabel.text = endedLabel.text
            
            firstProgressView.isHidden = false
            secondProgressView.isHidden = false
            thirdProgressView.isHidden = false
        default:
            break
        }
    }
    
}

class InvoiceViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    var data: Data!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global().async {
            let timestamp = Date().timestamp
            var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            url.appendPathComponent("\(timestamp)")
            do {
                try self.data.write(to: url)
                print(url)
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.webView.load(self.data, mimeType: "application/pdf", textEncodingName: "", baseURL: url)
                }
            } catch {
                print(error)
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: false)
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    @IBAction func shareData() {
        let activityViewController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
}
