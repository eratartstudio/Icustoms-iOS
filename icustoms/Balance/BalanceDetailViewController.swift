//
//  BalanceDetailViewController.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 27/03/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit

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
    
    private (set) var isPresented: Bool = false
    
    var transaction: BalanceTransaction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionLabel.text = transaction.description
        let price = transaction.amount.presentable()
        priceLastLabel.text = "." + price.last + " P"
        if transaction.transactionType == .substract {
            priceFirstLabel.text = price.first
            priceFirstLabel.textColor = .black
            priceLastLabel.textColor = .lightGray
        } else {
            priceFirstLabel.text = "+" + price.first
            priceFirstLabel.textColor = UIColor(red: 107/255, green: 187/255, blue: 92/255, alpha: 1) // 145 203 132
            priceLastLabel.textColor = UIColor(red: 145/255, green: 203/255, blue: 132/255, alpha: 1)
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.dateFormat = "dd MMMM yyyy, HH:mm"
        dateLabel.text = dateFormatter.string(from: transaction.dateObject)
        view.layoutIfNeeded()
        topViewScrollConstraint.constant = scrollView.frame.height/2
        view.layoutIfNeeded()
    }
    
    func present(from controller: UIViewController) {
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
    
}
