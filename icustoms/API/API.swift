//
//  API.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 22/03/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import Foundation
import Alamofire
import DKExtensions

class API: HTTP {
    
    static let `default` = API()
    
    private override init() {
        super.init()
        printLogs = true
    }
    
    let host: String = "http://lk.intrise.ru/api"
    
    let isTest = true
    //code: 4827
    
    var authorizationHeaders: [String : String] {
        guard let token = Database.default.currentUser()?.token else { return [:] }
        return ["Authorization": "Bearer " + token]
    }
}


//MARK: Authrization

extension API {
    
    func getSms(_ phone: String, success: @escaping (AuthorizationResponse?) -> Void, failure: Failure? = nil) {
        let ph = phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "+", with: "")
        if isTest {
            let data = "{\"phone\":\"79167105744\",\"accounts\":[{\"id\":116,\"is_blocked\":false,\"company\":\"Пятый элемент\"}]}".data(using: .utf8)!
            success(try! JSONDecoder().decode(AuthorizationResponse.self, from: data))
            return
        }
        postModel(host.auth.getSMS, params: ["phone": ph as AnyObject], success: { (response: AuthorizationResponse?, statusCode: Int) in
            success(response)
        }, failure: failure)
    }
    
    func checkSms(_ phone: String, code: Int, accountId: Int, success: @escaping (TokenResponse?) -> Void, failure: Failure? = nil) {
        let ph = phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "+", with: "")
        print(["id": accountId, "code": code, "phone": ph])
        postModel(host.auth.checkSMS, params: ["id": accountId as AnyObject, "code": code as AnyObject, "phone": ph as AnyObject], success: { (response: TokenResponse?, statusCode: Int) in
            success(response)
        }, failure: failure)
    }
    
}


//MARK: Orders

extension API {
    
    func orders(success: @escaping ([Order]) -> Void, failure: Failure? = nil) {
        getModel(host.mobile.orders, headers: authorizationHeaders, success: { (response: [Order]?, statusCode: Int) in
            success(response ?? [])
        }, failure: failure)
    }
    
}


//MARK: Customs

extension API {
    
    func customs(success: @escaping ([Custom]) -> Void, failure: Failure? = nil) {
        getModel(host.mobile.customs, headers: authorizationHeaders, success: { (response: [Custom]?, statusCode: Int) in
            success(response ?? [])
        }, failure: failure)
    }
    
}


//MARK: Balance

extension API {
    
    func balance(success: @escaping ([BalanceTransaction]) -> Void, failure: Failure? = nil) {
        getModel(host.mobile.balance, headers: authorizationHeaders, success: { (response: [BalanceTransaction]?, statusCode: Int) in
            success(response ?? [])
        }, failure: failure)
    }
    
}


//MARK: Endpoints Extension

extension String {
    
    var auth: String {
        return self + "/auth"
    }
    
    var getSMS: String {
        return self + "/get_sms"
    }
    
    var checkSMS: String {
        return self + "/check_sms"
    }
    
    var mobile: String {
        return self + "/mobile"
    }
    
    var orders: String {
        return self + "/orders"
    }
    
    var customs: String {
        return self + "/customs"
    }
    
    var balance: String {
        return self + "/balance"
    }
    
}
