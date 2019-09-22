//
//  Custom.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 28/03/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import Foundation

struct Custom: Decodable {
    
    let actualDate: String
    let totalAvans: Double
    let totalToll: Double
    let custom: CustomItem
    let customPayments: [CustomPayment]
    
    enum CodingKeys: CodingKey {
        case actualDate
        case totalAvans
        case totalToll
        case custom
        case customPayments
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        actualDate = try container.decode(String.self, forKey: .actualDate)
        totalAvans = (try? container.decode(Double.self, forKey: .totalAvans)) ?? 0
        totalToll = (try? container.decode(Double.self, forKey: .totalToll)) ?? 0
        custom = try container.decode(CustomItem.self, forKey: .custom)
        customPayments = try container.decode([CustomPayment].self, forKey: .customPayments)
    }
}

struct CustomItem: Decodable {
    let id: Int
    let code: Int
    let name: String
    let isEls: Bool
}

struct CustomPayment: Decodable {
    let id: Int
    let orderNum: Int?
    let kbk: String?
    let type: Int
    let orderDate: String?
    let sum: String
    let transferDate: String?
    
    enum CodingKeys: CodingKey {
        case id
        case orderNum
        case orderDate
        case kbk
        case type
        case sum
        case transferDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        orderNum = try? container.decode(Int.self, forKey: .orderNum)
        orderDate = try? container.decode(String.self, forKey: .orderDate)
        kbk = try? container.decode(String.self, forKey: .kbk)
        type = (try? container.decode(Int.self, forKey: .type)) ?? 1
        sum = (try? container.decode(String.self, forKey: .sum)) ?? ""
        transferDate = try? container.decode(String.self, forKey: .transferDate)
    }
}
