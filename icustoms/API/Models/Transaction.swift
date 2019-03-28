//
//  Transaction.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 28/03/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import Foundation

enum BalanceTransactionType: String {
    case substract, add
}

struct BalanceTransaction: Decodable {
    
    let total: Double
    let date: String
    let description: String
    let type: String
    let invoiceId: Int
    let clientPaymentId: Int
    
    var timestamp = 0
    
    enum CodingKeys: CodingKey {
        case total
        case date
        case description
        case type
        case invoiceId
        case clientPaymentId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        total = try container.decode(Double.self, forKey: .total)
        date = (try? container.decode(String.self, forKey: .date)) ?? ""
        description = (try? container.decode(String.self, forKey: .description)) ?? ""
        type = (try? container.decode(String.self, forKey: .type)) ?? ""
        invoiceId = (try? container.decode(Int.self, forKey: .invoiceId)) ?? 0
        clientPaymentId = (try? container.decode(Int.self, forKey: .clientPaymentId)) ?? 0
        
        timestamp = Int(dateObject.startOfDay.timestamp)
    }
    
    var transactionType: BalanceTransactionType {
        return BalanceTransactionType(rawValue: type) ?? .add
    }
    
    var amount: Double {
        if transactionType == .substract {
            return -total
        }
        return total
    }
    
    var dateObject: Date {
        return Date.from(string: date, format: "yyyy-MM-dd'T'HH:mm:ssZZZ")
    }
    
}
