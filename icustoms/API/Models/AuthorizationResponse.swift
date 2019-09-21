//
//  AuthorizationResponse.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 28/03/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import Foundation

struct AuthorizationResponse: Decodable {
    let phone: String
    let accounts: [AccountItem]
}
