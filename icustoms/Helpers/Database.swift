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
    
    func add(_ object: Object) {
        guard let realm = try? realmInstance() else { return }
        try? realm.safeWrite {
            realm.add(object)
        }
    }
    
    func deleteUser() {
        guard let realm = try? realmInstance() else { return }
        try? realm.safeWrite {
            realm.delete(realm.objects(User.self))
        }
        profileSettings = nil
    }
    
    func currentUser() -> User? {
        let realm = try? realmInstance()
        return realm?.objects(User.self).first
    }
    
    var profileSettings: ProfileSettings? {
        get {
            guard let data = UserDefaults.standard.data(forKey: "profile_settings") else {
                return nil
            }
            return try? JSONDecoder().decode(ProfileSettings.self, from: data)
        }
        set {
            guard let settings = newValue else {
                UserDefaults.standard.set(nil, forKey: "profile_settings")
                return
            }
            API.default.updateProfileSettings(settings)
            let data = try? JSONEncoder().encode(settings)
            UserDefaults.standard.set(data, forKey: "profile_settings")
        }
    }
    
}

class User: Object {
    @objc dynamic var token: String = ""
}
