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
    @IBOutlet weak var topFilterConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var filterView: FilterView!
    
    var searchController: UISearchController!
    
    var orders: [[Order]] = []
    var filteredOrders: [[Order]] = []
    
    var filter: FilterOrder? = nil
    
    var searchTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterView.delegate = self
        
        createSearchController()
        
        topFilterConstraint.constant = -UIScreen.main.bounds.height
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "filter"), style: .plain, target: self, action: #selector(showFilterView))
        
        SVProgressHUD.show()
        API.default.orders(success: { [weak self] (orders) in
            SVProgressHUD.dismiss()
            
            let items = orders.filter { !$0.isEnded }.sorted { $0.id > $1.id }
            let closed = orders.filter { $0.isEnded }.sorted { $0.id > $1.id }
            
            self?.orders = [items, closed]
            self?.tableView.reloadData()
        }) { [weak self] (error, statusCode) in
            SVProgressHUD.dismiss()
            self?.showAlert("Ошибка", message: "Невозможно загрузить заказы")
        }
    }
    
    func createSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    @IBAction func searchStartAction() {
//        searchController.isActive = true
        searchController.searchBar.becomeFirstResponder()
    }

    
    @objc func showFilterView() {
        topFilterConstraint.constant = 0
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Закрыть", style: .plain, target: self, action: #selector(hideFilterView))
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func hideFilterView() {
        topFilterConstraint.constant = -UIScreen.main.bounds.height
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "filter"), style: .plain, target: self, action: #selector(showFilterView))
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
}

extension MainViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    
    func willPresentSearchController(_ searchController: UISearchController) {
        hideFilterView()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else {
            filteredOrders = []
            tableView.reloadData()
            return
        }
        searchTimer.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { [weak self] (timer) in
            API.default.search(text, filter: self?.filter, success: { [weak self] (items) in
                let items = items.filter { !$0.isEnded }.sorted { $0.id > $1.id }
                let closed = items.filter { $0.isEnded }.sorted { $0.id > $1.id }
                
                self?.filteredOrders = [items, closed]
                self?.tableView.reloadData()
            }, failure: { (error, statusCode) in
                self?.showAlert("Ошибка", message: "Невозможно загрузить заказы")
            })
        })
        
    }
    
}


extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchController.isActive || filter != nil ? filteredOrders.count : orders.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive || filter != nil {
            return filteredOrders[section].count
        }
        return orders[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 50 : CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 1 else { return nil }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        view.backgroundColor = .clear
        let label = UILabel(frame: CGRect(x: 10, y: 15, width: UIScreen.main.bounds.width - 20, height: 30))
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.text = "Завершенные заказы"
        view.addSubview(label)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let order: Order
        if searchController.isActive || filter != nil {
            order = filteredOrders[indexPath.section][indexPath.row]
        } else {
            order = orders[indexPath.section][indexPath.row]
        }
        if order.isEnded {
            let cell = tableView.dequeueReusableCell(EndedOrderTableCell.self, for: indexPath)
            cell.order = order
            return cell
        }
        let cell = tableView.dequeueReusableCell(ActiveOrderTableCell.self, for: indexPath)
        cell.order = order
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let order: Order
        if searchController.isActive || filter != nil {
            order = filteredOrders[indexPath.section][indexPath.row]
        } else {
            order = orders[indexPath.section][indexPath.row]
        }
        let controller = OrderDetailViewController.controller()
        controller.order = order
        push(controller, animated: true)
    }
    
}

extension MainViewController: FilterViewDelegate {
    
    func filterView(_ view: FilterView, didSave filter: FilterOrder) {
        hideFilterView()
        SVProgressHUD.show()
        API.default.search("", filter: filter, success: { [weak self] (items) in
            SVProgressHUD.dismiss()
            let items = items.filter { !$0.isEnded }.sorted { $0.id > $1.id }
            let closed = items.filter { $0.isEnded }.sorted { $0.id > $1.id }
            
            self?.filteredOrders = [items, closed]
            self?.tableView.reloadData()
            self?.filter = filter
            self?.tableView.reloadData()
        }) { [weak self] (error, statusCode) in
            SVProgressHUD.dismiss()
            self?.showAlert("Ошибка", message: "Невозможно загрузить заказы")
        }
    }
    
}

import UICircularProgressRing

class ActiveOrderTableCell: UITableViewCell {
    
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var paidLabel: UILabel!
    @IBOutlet weak var analyticsCircleContainerView: UIView!
    @IBOutlet weak var analyticsCircleView: UICircularProgressRing!
    
    @IBOutlet weak var releaseCircleContainerView: UIView!
    @IBOutlet weak var releaseCircleView: UICircularProgressRing!
    
    @IBOutlet weak var analyticsCompleted: UIImageView!
    @IBOutlet weak var declarationCompleted: UIImageView!
    @IBOutlet weak var releaseCompleted: UIImageView!
    
    @IBOutlet weak var declarationView: UIView!
    @IBOutlet weak var endedView: UIView!
    
    @IBOutlet weak var analyticLabel: UILabel!
    @IBOutlet weak var declarationLabel: UILabel!
    @IBOutlet weak var releaseLabel: UILabel!
    @IBOutlet weak var endedLabel: UILabel!
    
    @IBOutlet weak var firstProgressView: UIView!
    @IBOutlet weak var secondProgressView: UIView!
    
    let activeColor: UIColor = UIColor(red: 111/255, green: 184/255, blue: 98/255, alpha: 1)
    let inactiveColor: UIColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    
    var order: Order? {
        didSet {
            updateContent()
        }
    }
    
    private func updateContent() {
        guard let order = order else { return }
        
        orderIdLabel.text = order.orderId
        statusLabel.text = order.status?.name
        paidLabel.isHidden = order.isPaid
        dateLabel.text = Date.from(string: order.createdAt, format: "yyyy-MM-dd'T'HH:mm:ssZZZ").string(with: "dd MMMM yyyy").uppercased()
        prepareStatus(order.status?.id ?? 0)
    }
    
    func prepareStatus(_ status: Int) {
        switch status {
        case 1:
            analyticsCircleContainerView.isHidden = true
            releaseCircleContainerView.isHidden = true
            analyticsCompleted.isHidden = true
            declarationCompleted.isHidden = true
            releaseCompleted.isHidden = true
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
        case 2:
            analyticsCircleContainerView.isHidden = false
            releaseCircleContainerView.isHidden = true
            analyticsCompleted.isHidden = true
            declarationCompleted.isHidden = true
            releaseCompleted.isHidden = true
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
        case 3:
            analyticsCompleted.isHidden = false
            declarationCompleted.isHidden = true
            releaseCompleted.isHidden = true
            releaseCircleContainerView.isHidden = true
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
        case 4, 5, 6, 7:
            analyticsCompleted.isHidden = false
            declarationCompleted.isHidden = false
            releaseCompleted.isHidden = true
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
        case 8:
            analyticsCompleted.isHidden = false
            declarationCompleted.isHidden = false
            releaseCompleted.isHidden = false
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


class EndedOrderTableCell: UITableViewCell {
    
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var order: Order? {
        didSet {
            updateContent()
        }
    }
    
    private func updateContent() {
        guard let order = order else { return }
        
        orderIdLabel.text = order.orderId
        dateLabel.text = Date.from(string: order.createdAt, format: "yyyy-MM-dd'T'HH:mm:ssZZZ").string(with: "dd MMMM yyyy").uppercased()
    }
    
}
