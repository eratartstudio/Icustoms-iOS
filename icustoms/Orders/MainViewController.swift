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
        print(reviewInputCosmosView.settings.starMargin)
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
