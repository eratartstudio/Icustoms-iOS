//
//  NotificationResponse.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 04/04/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import Foundation

struct NotificationResponse: Decodable {
    let first: Bool
    let second: Bool
    let third: Bool
    let four: Bool
    let five: Bool
    let six: Bool
    let seven: Bool
    let eight: Bool
    
    var array: [Bool] {
        return [first, second, third, four, five, six, seven, eight]
    }
    
    enum CodingKeys: String, CodingKey {
        case first = "1"
        case second = "2"
        case third = "3"
        case four = "4"
        case five = "5"
        case six = "6"
        case seven = "7"
        case eight = "8"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        first = (try? container.decode(Bool.self, forKey: .first)) ?? false
        second = (try? container.decode(Bool.self, forKey: .second)) ?? false
        third = (try? container.decode(Bool.self, forKey: .third)) ?? false
        four = (try? container.decode(Bool.self, forKey: .four)) ?? false
        five = (try? container.decode(Bool.self, forKey: .five)) ?? false
        six = (try? container.decode(Bool.self, forKey: .six)) ?? false
        seven = (try? container.decode(Bool.self, forKey: .seven)) ?? false
        eight = (try? container.decode(Bool.self, forKey: .eight)) ?? false
    }
}
