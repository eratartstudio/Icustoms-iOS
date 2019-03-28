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
    
    enum CodingKeys: CodingKey {
        case actualDate
        case totalAvans
        case totalToll
        case custom
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        actualDate = try container.decode(String.self, forKey: .actualDate)
        totalAvans = (try? container.decode(Double.self, forKey: .totalAvans)) ?? 0
        totalToll = (try? container.decode(Double.self, forKey: .totalToll)) ?? 0
        custom = try container.decode(CustomItem.self, forKey: .custom)
    }
    
}

struct CustomItem: Decodable {
    let id: Int
    let code: Int
    let name: String
    let isEls: Bool
}
