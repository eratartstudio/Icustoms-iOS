//
//  Database.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 22/03/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import Foundation
import RealmSwift

class Database {
    
    static let `default` = Database()
    private let privateRealm: Realm
    
    private init() {
        privateRealm = try! Realm()
    }
    
    func realmInstance() throws -> Realm {
        return Thread.isMainThread ? privateRealm : try! Realm()
    }
    
    func currentUser() -> User? {
        let realm = try? realmInstance()
        return realm?.objects(User.self).first
    }
    
}

class User: Object {
    @objc dynamic var id = 0
}
