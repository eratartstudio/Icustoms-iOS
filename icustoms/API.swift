//
//  API.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 22/03/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import Foundation
import Alamofire

struct AuthorizationResponse: Decodable {
    let phone: String
    let accounts: [AccountItem]
}

struct AccountItem: Decodable {
    let id: Int
    let company: String
    let is_blocked: Bool
}

struct TokenResponse: Decodable {
    let token: String
}

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
    
}

class API {
    
    static let `default` = API()
    
    let host: String = "http://lk.intrise.ru/api"
    
    let isTest = true
    //code: 4827
    
    func getSms(_ phone: String, _ completion: @escaping (AuthorizationResponse?) -> Void) {
        let ph = phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "+", with: "")
        if isTest {
            let data = "{\"phone\":\"79167105744\",\"accounts\":[{\"id\":116,\"is_blocked\":false,\"company\":\"Пятый элемент\"}]}".data(using: .utf8)!
            completion(try! JSONDecoder().decode(AuthorizationResponse.self, from: data))
            return
        }
        
        request(host.auth.getSMS, method: .post, parameters: ["phone": ph], headers: nil) { (response: AuthorizationResponse?) in
            completion(response)
        }
    }
    
    func checkSms(_ phone: String, code: Int, accountId: Int, _ completion: @escaping (TokenResponse?) -> Void) {
        let ph = phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "+", with: "")
        print(["id": accountId, "code": code, "phone": ph])
        request(host.auth.checkSMS, method: .post, parameters: ["id": accountId, "code": code, "phone": ph], headers: nil) { (response: TokenResponse?) in
            completion(response)
        }
    }
    
    private func request<T: Decodable>(_ url: String, method: HTTPMethod, parameters: Parameters?, headers: HTTPHeaders?, _ completion: @escaping (T?) -> Void) {
        print("\(method.rawValue) \(url)")
        Alamofire.request(url, method: method, parameters: parameters, headers: headers).responseData { (response) in
            guard let data = response.data else {
                completion(nil)
                return
            }
            if let string = String(data: data, encoding: .utf8) {
                print("Response: ")
                print(string)
            }
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                completion(result)
            } catch {
                print(error)
                completion(nil)
            }
        }
        
    }
    
}
