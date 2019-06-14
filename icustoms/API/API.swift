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

struct File: Decodable {
    let id: Int
    let type: FileType
    let name: String
    let number: String
    let date: String
    let expired: String?
    let fileSize: Int
    let mimeType: String?
    let createdAt: String?
    
    enum CodingKeys: CodingKey {
        case id
        case type
        case name
        case number
        case date
        case expired
        case fileSize
        case mimeType
        case createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        type = try container.decode(FileType.self, forKey: .type)
        name = try container.decode(String.self, forKey: .name)
        number = try container.decode(String.self, forKey: .number)
        date = try container.decode(String.self, forKey: .date)
        expired = try? container.decode(String.self, forKey: .expired)
        fileSize = (try? container.decode(Int.self, forKey: .fileSize)) ?? 0
        mimeType = try? container.decode(String.self, forKey: .mimeType)
        createdAt = try container.decode(String.self, forKey: .createdAt)
    }
 
}

struct FileType: Decodable {
    let name: String
    let code: String
}


class API: HTTP {
    
    static let `default` = API()
    
    private override init() {
        super.init()
        printLogs = false
    }
    
    let host: String = "http://lk.intrise.ru/api"
    
    let isTest = false
    //code: 6455
    
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
    
    func setReview(_ orderId: Int, score: Int, text: String, success: @escaping (Bool) -> Void, failure: Failure? = nil) {
        post(host.mobile.orders(orderId).review, params: ["text": text, "score": score] as [String : AnyObject], headers: authorizationHeaders, encoding: .json, success: { (data, statusCode) in
            success(statusCode >= 200 && statusCode < 300)
        }, failure: failure)
    }
    
    func search(_ text: String, filter: FilterOrder? = nil, success: @escaping ([Order]) -> Void, failure: Failure? = nil) {
        var params = filter?.data ?? [:]
        params["keyword"] = text
        postModel(host.mobile.orders.search, params: params as [String : AnyObject], headers: authorizationHeaders, encoding: .json, success: { (response: [Order]?, statusCode) in
            success(response ?? [])
        }, failure: failure)
    }
    
    func invoiceFile(_ orderId: Int, success: @escaping (Data) -> Void, failure: Failure? = nil) {
        print(host.mobile.invoices(orderId).pdf)
        self.get(invoiceFileLink(orderId), headers: authorizationHeaders, success: { (data, statusCode) in
            print(statusCode)
            print(data)
            success(data)
        }, failure: failure)
    }
    
    func invoiceFileLink(_ orderId: Int) -> String {
        return host.mobile.invoices(orderId).pdf
    }
    
    func downloadFiles(_ fileId: Int, _ success: @escaping (Data) -> Void, failure: Failure? = nil) {
        print(authorizationHeaders)
        self.get(host.mobile.files(fileId), headers: authorizationHeaders, success: { (data, statusCode) in
            success(data)
        }, failure: failure)
    }
    
    func files(_ orderId: Int, _ success: @escaping ([File]) -> Void, failure: Failure? = nil) {
        getModel(host.mobile.orderFiles(orderId), headers: authorizationHeaders, success: { (response: [File]?, statusCode: Int) in
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
    
    func custom(_ id: Int, success: @escaping (Custom?) -> Void, failure: Failure? = nil) {
        getModel(host.mobile.customs + "/\(id)", headers: authorizationHeaders, success: { (response: Custom?, statusCode: Int) in
            success(response)
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


//MARK: Pushes

extension API {
    
    func setDeviceToken(_ token: String, success: ((Bool) -> Void)? = nil, failure: Failure? = nil) {
        post(host.mobile.client.settings.firebaseToken, params: ["firebaseToken": token as AnyObject], headers: authorizationHeaders, encoding: .json, success: { (data, statusCode) in
            success?(statusCode >= 200 && statusCode < 300)
        }, failure: failure)
    }
    
    func deleteDeviceToken(_ token: String, success: ((Bool) -> Void)? = nil, failure: Failure? = nil) {
        delete(host.mobile.client.settings.firebaseToken, params: ["firebaseToken": token as AnyObject], headers: authorizationHeaders, encoding: .json, success: { (data, statusCode) in
            success?(statusCode >= 200 && statusCode < 300)
        }, failure: failure)
    }
    
}


//MARK: Settings

extension API {
    
    func profile(success: @escaping (Profile?) -> Void, failure: Failure? = nil) {
        getModel(host.mobile.client.profile, headers: authorizationHeaders, success: { (response: Profile?, statusCode: Int) in
            success(response)
        }, failure: failure)
    }
    
    func profileSettings(success: @escaping (ProfileSettings?) -> Void, failure: Failure? = nil) {
        getModel(host.mobile.client.settings.profile, headers: authorizationHeaders, success: { (response: ProfileSettings?, statusCode: Int) in
            success(response)
        }, failure: failure)
    }
    
    func updateProfileSettings(_ settings: ProfileSettings, success: ((Bool) -> Void)? = nil, failure: Failure? = nil) {
        var params = [String : AnyObject]()
        let pushSettings = settings.pushNotification.pushNotification
        params["pushNotification"] = ["status": pushSettings.status, "balance": pushSettings.balance, "other": pushSettings.other] as AnyObject
        patch(host.mobile.client.settings.profile, params: params, headers: authorizationHeaders, encoding: .json, success: { (data, statusCode) in
            success?(statusCode >= 200 && statusCode < 300)
        }, failure: failure)
    }
    
    func emailSettings(success: @escaping (NotificationResponse?) -> Void, failure: Failure? = nil) {
        getModel(host.mobile.client.settings.email, headers: authorizationHeaders, success: { (response: NotificationResponse?, statusCode: Int) in
            success(response)
        }, failure: failure)
    }
    
    func updateEmailSettings(_ values: [Bool], _ success: ((Bool) -> Void)? = nil, failure: Failure? = nil) {
        guard values.count >= 8 else { success?(false); return }
        var params: [String : Bool] = [:]
        for (index, value) in values.enumerated() {
            params["\(index + 1)"] = value
        }
        patch(host.mobile.client.settings.email, params: params as [String : AnyObject], headers: authorizationHeaders, encoding: .json, success: { (data, statusCode) in
            success?(statusCode >= 200 && statusCode < 300)
        }, failure: failure)
    }
    
    func smsSettings(success: @escaping (NotificationResponse?) -> Void, failure: Failure? = nil) {
        getModel(host.mobile.client.settings.sms, headers: authorizationHeaders, success: { (response: NotificationResponse?, statusCode: Int) in
            success(response)
        }, failure: failure)
    }
    
    func updateSmsSettings(_ values: [Bool], _ success: ((Bool) -> Void)? = nil, failure: Failure? = nil) {
        guard values.count >= 8 else { success?(false); return }
        var params: [String : Bool] = [:]
        for (index, value) in values.enumerated() {
            params["\(index + 1)"] = value
        }
        patch(host.mobile.client.settings.sms, params: params as [String : AnyObject], headers: authorizationHeaders, encoding: .json, success: { (data, statusCode) in
            success?(statusCode >= 200 && statusCode < 300)
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
    
    func orders(_ id: Int) -> String {
        return self + "/orders/\(id)"
    }
    
    var customs: String {
        return self + "/customs"
    }
    
    var balance: String {
        return self + "/balance"
    }
    
    var client: String {
        return self + "/client"
    }
    
    var profile: String {
        return self + "/profile"
    }
    
    var settings: String {
        return self + "/settings"
    }
    
    var email: String {
        return self + "/email"
    }
    
    var sms: String {
        return self + "/sms"
    }
    
    func orderFiles(_ orderId: Int) -> String {
        return self + "/order_files/\(orderId)"
    }
    
    func files(_ fileId: Int) -> String {
        return self + "/files/\(fileId)"
    }
    
    func invoices(_ orderId: Int) -> String {
        return self + "/invoices/\(orderId)"
    }
    
    var pdf: String {
        return self + "/pdf"
    }
    
    var search: String {
        return self + "/search"
    }
    
    var firebaseToken: String {
        return self + "/firebase_token"
    }
    
    var review: String {
        return self + "/review"
    }
    
}
