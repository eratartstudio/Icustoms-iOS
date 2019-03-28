//
//  AccountItem.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 28/03/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import Foundation

struct AccountItem: Decodable {
    let id: Int
    let company: String
    let is_blocked: Bool
}
