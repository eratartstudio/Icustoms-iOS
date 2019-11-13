//
//  ViewController.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 21/03/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit
import SVProgressHUD
import Cosmos

class MainViewController: UIViewController {//, Localizable 
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topFilterConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var filterView: FilterView!
    
    var searchController: UISearchController!
    
    var reviewClicked: Bool = false
    var orders: [[Order]] = []
    var filteredOrders: [[Order]] = []
    
    var filter: FilterOrder? = nil
    
    var searchTimer: Timer?
    
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    //var locale: Localization!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
            let statusBar = UIView(frame: UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero)
            statusBar.backgroundColor = UIColor(named: "purpleColor")
             UIApplication.shared.keyWindow?.addSubview(statusBar)
        } else {
            // Fallback on earlier versions
        }
        
        //locale = Localization.current()
        //localize(locale)
        
        refreshControl.addTarget(self, action: #selector(update), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
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
            self?.showAlert("Ошибка".localizedSafe, message: "Невозможно загрузить заказы".localizedSafe)
        }
        
        NotificationManager.default.registerPushNotifications()
    }
    
    //    func localize(_ locale: Localization) {
    //        self.locale = locale
    //        createSearchController()
    //        update()
    //    }
    
    @objc func update() {
        if searchController.isActive || filter != nil {
            API.default.search(searchController.searchBar.text ?? "", filter: self.filter, success: { [weak self] (items) in
                var filtered = items.filter { !$0.isEnded }.sorted { $0.id > $1.id }
                var closed = items.filter { $0.isEnded }.sorted { $0.id > $1.id }
                
                if let paidType = self?.filter?.paidType, paidType != .all {
                    filtered = filtered.filter { paidType == .paid ? $0.isPaid : !$0.isPaid }
                    closed = closed.filter { paidType == .paid ? $0.isPaid : !$0.isPaid }
                }
                
                self?.filteredOrders = [filtered, closed]
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
                SVProgressHUD.dismiss()
                }, failure: { [weak self] (error, statusCode) in
                    self?.refreshControl.endRefreshing()
                    self?.showAlert("Ошибка".localizedSafe, message: "Невозможно загрузить заказы".localizedSafe)
            })
        } else {
            API.default.orders(success: { [weak self] (orders) in
                let items = orders.filter { !$0.isEnded }.sorted { $0.id > $1.id }
                let closed = orders.filter { $0.isEnded }.sorted { $0.id > $1.id }
                
                self?.orders = [items, closed]
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
            }) { [weak self] (error, statusCode) in
                self?.refreshControl.endRefreshing()
                self?.showAlert("Ошибка".localizedSafe, message: "Невозможно загрузить заказы".localizedSafe)
            }
        }
    }
    
    func createSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Поиск".localizedSafe
        searchController.searchBar.setValue("Отмена".localizedSafe, forKey: "cancelButtonText")
        searchController.searchBar.setPlaceholder(textColor: .white)
        searchController.searchBar.setSearchImage(color: .white)
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Закрыть".localizedSafe, style: .plain, target: self, action: #selector(hideFilterView))
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
    
    func updateOrder(_ order: Order, section: Int) {
        guard section < orders.count else { return }
        var items = orders[section]
        guard let index = items.firstIndex(where: { $0.id == order.id }) else { return }
        items[index] = order
        orders[section] = items
        print(order)
        tableView.reloadData()
    }
}

extension MainViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    func willPresentSearchController(_ searchController: UISearchController) {
        hideFilterView()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredOrders = []
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else {
            filteredOrders = []
            tableView.reloadData()
            return
        }
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { [weak self] (timer) in
            API.default.search(text, filter: self?.filter, success: { [weak self] (items) in
                var filtered = items.filter { !$0.isEnded }.sorted { $0.id > $1.id }
                var closed = items.filter { $0.isEnded }.sorted { $0.id > $1.id }
                
                if let paidType = self?.filter?.paidType, paidType != .all {
                    filtered = filtered.filter { paidType == .paid ? $0.isPaid : !$0.isPaid }
                    closed = closed.filter { paidType == .paid ? $0.isPaid : !$0.isPaid }
                }
                
                self?.filteredOrders = [filtered, closed]
                self?.tableView.reloadData()
                }, failure: { (error, statusCode) in
                    self?.showAlert("Ошибка".localizedSafe, message: "Невозможно загрузить заказы".localizedSafe)
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
        var count = orders[section].count
        if searchController.isActive || filter != nil {
            count = filteredOrders[section].count
        }
        
        guard count > 0 else { return nil }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        view.backgroundColor = .clear
        let label = UILabel(frame: CGRect(x: 10, y: 15, width: UIScreen.main.bounds.width - 20, height: 30))
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.text = "Завершенные заказы".localizedSafe
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
            //cell.locale = locale
            cell.order = order
            cell.controller = self
            return cell
        }
        let cell = tableView.dequeueReusableCell(ActiveOrderTableCell.self, for: indexPath)
        //cell.locale = locale
        cell.order = order
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if reviewClicked {
            reviewClicked = false
            return
        }
        let order: Order
        if searchController.isActive || filter != nil {
            order = filteredOrders[indexPath.section][indexPath.row]
            navigationController?.isNavigationBarHidden = false
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
        //update()
        hideFilterView()
        SVProgressHUD.show()
        API.default.search("", filter: filter, success: { [weak self] (items) in
            var filtered = items.filter { !$0.isEnded }.sorted { $0.id > $1.id }
            var closed = items.filter { $0.isEnded }.sorted { $0.id > $1.id }
            
            if let paidType = self?.filter?.paidType, paidType != .all {
                filtered = filtered.filter { paidType == .paid ? $0.isPaid : !$0.isPaid }
                closed = closed.filter { paidType == .paid ? $0.isPaid : !$0.isPaid }
            }
            
            self?.filteredOrders = [filtered, closed]
            //            self?.tableView.reloadData()
            self?.filter = filter
            self?.tableView.reloadData()
            self?.update()
            self?.tableView.setContentOffset(.zero, animated: true)
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            //                SVProgressHUD.dismiss()
            //            }
        }) { [weak self] (error, statusCode) in
            SVProgressHUD.dismiss()
            self?.showAlert("Ошибка".localizedSafe, message: "Невозможно загрузить заказы".localizedSafe)
        }
    }
}
