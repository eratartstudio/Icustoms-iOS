//
//  BalanceDetailViewController.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 27/03/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit
import SVProgressHUD

class BalanceDetailViewController: UIViewController, UIScrollViewDelegate {
    
    static func storyboardInstance() -> BalanceDetailViewController {
        return Storyboard.Main.instance.instantiateViewController(withIdentifier: "BalanceDetailViewController") as! BalanceDetailViewController
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topViewScrollConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceFirstLabel: UILabel!
    @IBOutlet weak var priceLastLabel: UILabel!
    
    @IBOutlet weak var invoiceButton: UIButton!
    @IBOutlet weak var invoiceImage: UIImageView!
    @IBOutlet weak var invoiceLabel: UILabel!
    
    @IBOutlet weak var invoiceLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var invoiceLableBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var invoiceLabelTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var invoiceButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var invoiceButtonBottomConstraint: NSLayoutConstraint!
    
    
    private (set) var isPresented: Bool = false
    
    var transaction: BalanceTransaction!
    
    weak var controller: BalanceViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        descriptionLabel.text = transaction.description
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
            
            invoiceImage.isHidden = true
            
            invoiceLabelHeightConstraint.constant = 0
            invoiceLableBottomConstraint.constant = 0
            invoiceLabelTopConstraint.constant = 0
            
            invoiceButtonTopConstraint.constant = 0
            invoiceButtonBottomConstraint.constant = 0
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru".localizedSafe)
        
        let calendar = NSCalendar.current
        let hour = calendar.component(.hour, from: transaction.dateObject)
        let minutes = calendar.component(.minute, from: transaction.dateObject)
        
        if "\(hour):\(minutes)" == "0:0" {
            dateFormatter.dateFormat = "dd MMMM yyyy"
        } else {
            dateFormatter.dateFormat = "dd MMMM yyyy, HH:mm"
        }
        
        dateLabel.text = dateFormatter.string(from: transaction.dateObject)
        view.layoutIfNeeded()
        topViewScrollConstraint.constant = scrollView.frame.height/2
        view.layoutIfNeeded()
    }
    
    func present(from controller: BalanceViewController) {
        self.controller = controller
        controller.present(self, animated: false) {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollView.frame.height/2), animated: true)
            self.scrollView.isScrollEnabled = false
            UIView.animate(withDuration: 0.3, animations: {
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            }, completion: { _ in
                self.isPresented = true
                self.scrollView.isScrollEnabled = true
                self.scrollView.delegate = self
            })
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard isPresented else { return }
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4 * (scrollView.contentOffset.y/scrollView.frame.height))
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView.contentOffset == .zero {
            dismissController()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset == .zero {
            dismissController()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissController()
    }
    
    func dismissController() {
        scrollView.isScrollEnabled = false
        if scrollView.contentOffset != .zero {
            scrollView.setContentOffset(.zero, animated: true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isPresented = false
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func showInvoice() {
        dismiss(animated: false, completion: nil)
        controller?.showInvoice(transaction.invoiceId)
        print(transaction.invoiceId)
    }
}
