//
//  Profile.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 02/04/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import Foundation

struct Profile: Decodable {
    let id: Int
    let company: String
    let prefix: String
    let firstName: String
    let lastName: String
    let middleName: String
    let phone: String
    let email: String
}
