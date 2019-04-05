//
//  Order.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 28/03/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import Foundation
import DKExtensions

struct Order: Decodable {
    let id: Int
    let orderId: String
    let invoiceNumber: String
    let currency: OrderCurrency?
    let checkNetarif: Bool
    let createdAt: String
    let countGoods: Int
    let deliveryCost: String
    let deliveryCurrency: OrderCurrency?
    let bankComission: String
    let otherExpenses: String
    let invoiceWithoutExpenses: String
    let invoiceCfr: String
    let invoiceBeforeDO1: String
    let countPlacesDO1: Int
    let weightDO1: String
    let prepaid: String
    let toll: String
    let deliveryService: String
    let status: OrderStatus?
    let countReady: Int
    let countInWork: Int
    let countChecking: Int
    let countErrors: Int
    let isPaid: Bool
    
    var isEnded: Bool {
        return status?.id == 11
    }
    
    enum CodingKeys: CodingKey {
        case bankComission
        case checkNetarif
        case countChecking
        case countErrors
        case countGoods
        case countInWork
        case countPlacesDO1
        case countReady
        case createdAt
        case currency
        case deliveryCost
        case deliveryCurrency
        case deliveryService
        case id
        case invoiceBeforeDO1
        case invoiceCfr
        case invoiceNumber
        case invoiceWithoutExpenses
        case orderId
        case otherExpenses
        case prepaid
        case status
        case toll
        case weightDO1
        case isPaid
    }

    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        orderId = try container.decode(String.self, forKey: .orderId)
        invoiceNumber = (try? container.decode(String.self, forKey: .invoiceNumber)) ?? ""
        currency = try? container.decode(OrderCurrency.self, forKey: .currency)
        checkNetarif = (try? container.decode(Bool.self, forKey: .checkNetarif)) ?? false
        createdAt = (try? container.decode(String.self, forKey: .createdAt)) ?? ""
        countGoods = (try? container.decode(Int.self, forKey: .countGoods)) ?? 0
        deliveryCost = (try? container.decode(String.self, forKey: .deliveryCost)) ?? ""
        deliveryCurrency = try? container.decode(OrderCurrency.self, forKey: .deliveryCurrency)
        bankComission = (try? container.decode(String.self, forKey: .bankComission)) ?? ""
        otherExpenses = (try? container.decode(String.self, forKey: .otherExpenses)) ?? ""
        invoiceWithoutExpenses = (try? container.decode(String.self, forKey: .invoiceWithoutExpenses)) ?? ""
        invoiceCfr = (try? container.decode(String.self, forKey: .invoiceCfr)) ?? ""
        invoiceBeforeDO1 = (try? container.decode(String.self, forKey: .invoiceBeforeDO1)) ?? ""
        countPlacesDO1 = (try? container.decode(Int.self, forKey: .countPlacesDO1)) ?? 0
        weightDO1 = (try? container.decode(String.self, forKey: .weightDO1)) ?? ""
        prepaid = (try? container.decode(String.self, forKey: .prepaid)) ?? ""
        toll = (try? container.decode(String.self, forKey: .toll)) ?? ""
        deliveryService = (try? container.decode(String.self, forKey: .deliveryService)) ?? ""
        status = try? container.decode(OrderStatus.self, forKey: .status)
        countReady = (try? container.decode(Int.self, forKey: .countReady)) ?? 0
        countInWork = (try? container.decode(Int.self, forKey: .countInWork)) ?? 0
        countChecking = (try? container.decode(Int.self, forKey: .countChecking)) ?? 0
        countErrors = (try? container.decode(Int.self, forKey: .countErrors)) ?? 0
        isPaid = (try? container.decode(Bool.self, forKey: .isPaid)) ?? false
    }
}

struct OrderStatus: Decodable {
    let id: Int
    let name: String
}


struct OrderCurrency: Decodable {
    let code: String?
    let name: String?
    let rate: String?
}
