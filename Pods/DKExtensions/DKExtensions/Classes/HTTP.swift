//
//  HTTP.swift
//  DKExtensions
//
//  Created by Кузин Дмитрий on 27.03.2019.
//

import UIKit
import Alamofire

public enum MimeType: String {
    case png = "image/png"
    case jpeg = "image/jpeg"
    case formData = "multipart/form-data"
}

public enum HTTPEncoding {
    case json
    case url
}

open class HTTP {
    
    public typealias Success = ((_ data: Data, _ statusCode: Int) -> Void)
    public typealias Failure = ((_ error: Error, _ statusCode: Int) -> Void)
    
    public var printLogs: Bool = false
    
    public init() {}
    
    public private (set) var requestsCount: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = self.requestsCount > 0
            }
        }
    }
    
    private func encoding(_ type: HTTPEncoding) -> ParameterEncoding {
        return type == .json ? JSONEncoding.default : URLEncoding.default
    }

    private func execute(_ method: HTTPMethod = .get, urlString: String, params: Parameters? = nil, encoding: ParameterEncoding, headers: HTTPHeaders?, success: Success? = nil, failure: Failure? = nil) {

        requestsCount += 1
        if printLogs {
            print("\(method.rawValue) \(urlString) \(params ?? [:])")
        }
        Alamofire.request(urlString, method: method, parameters: params, encoding: encoding, headers: headers).responseData { (response) in
            if let data = response.data, self.printLogs {
                print("\(method.rawValue) response: ")
                print(String(data: data, encoding: .utf8)!)
            }
            self.requestsCount -= 1
            
            if self.isValid(statusCode: response.response?.statusCode ?? 0) {
                if let d = response.data {
                    success?(d, response.response?.statusCode ?? 0)
                } else {
                    success?(Data(), response.response?.statusCode ?? 0)
                }
            } else {
                failure?(self.handleError(response: response, urlString: urlString, method: method), response.response?.statusCode ?? 0)
            }
        }
    }
    
    
    // MARK: - HTTP Methods Decodable
    
    private func decode<T: Decodable>(_ data: Data) -> T? {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print(error)
            return nil
        }
    }
    
    public func getModel<T: Decodable>(_ urlString: String, params: [String: Any]? = nil, headers: [String: String]? = nil, success: ((_ response: T?, _ statusCode: Int) -> Void)? = nil, failure: Failure? = nil) {
        get(urlString, params: params, headers: headers, success: { (data, statusCode) in
            success?(self.decode(data), statusCode)
        }, failure: failure)
    }
    
    public func postModel<T: Decodable>(_ urlString: String, params: [String: AnyObject]? = nil, headers: [String: String]? = nil, encoding: HTTPEncoding = .url, success: ((_ response: T?, _ statusCode: Int) -> Void)? = nil, failure: Failure? = nil) {
        post(urlString, params: params, headers: headers, encoding: encoding, success: { (data, statusCode) in
            success?(self.decode(data), statusCode)
        }, failure: failure)
    }
    
    public func patchModel<T: Decodable>(_ urlString: String, params: [String: AnyObject]? = nil, headers: [String: String]? = nil, encoding: HTTPEncoding = .url, success: ((_ response: T?, _ statusCode: Int) -> Void)? = nil, failure: Failure? = nil) {
        patch(urlString, params: params, headers: headers, encoding: encoding, success: { (data, statusCode) in
            success?(self.decode(data), statusCode)
        }, failure: failure)
    }
    
    public func putModel<T: Decodable>(_ urlString: String, params: [String: AnyObject]? = nil, headers: [String: String]? = nil, encoding: HTTPEncoding = .url, success: ((_ response: T?, _ statusCode: Int) -> Void)? = nil, failure: Failure? = nil) {
        put(urlString, params: params, headers: headers, encoding: encoding, success: { (data, statusCode) in
            success?(self.decode(data), statusCode)
        }, failure: failure)
    }
    
    public func deleteModel<T: Decodable>(_ urlString: String, params: [String: AnyObject]? = nil, headers: [String: String]? = nil, encoding: HTTPEncoding = .url, success: ((_ response: T?, _ statusCode: Int) -> Void)? = nil, failure: Failure? = nil) {
        delete(urlString, params: params, headers: headers, encoding: encoding, success: { (data, statusCode) in
            success?(self.decode(data), statusCode)
        }, failure: failure)
    }
    
    
    // MARK: - HTTP Methods
    
    public func get(_ urlString: String, params: [String: Any]? = nil, headers: [String: String]? = nil, success: Success? = nil, failure: Failure? = nil) {
        execute(.get, urlString: urlString, params: params, encoding: URLEncoding.default, headers: headers, success: success, failure: failure)
    }
    
    public func post(_ urlString: String, params: [String: AnyObject]? = nil, headers: [String: String]? = nil, encoding: HTTPEncoding = .url, success: Success? = nil, failure: Failure? = nil) {
        execute(.post, urlString: urlString, params: params, encoding: self.encoding(encoding), headers: headers, success: success, failure: failure)
    }
    
    public func patch(_ urlString: String, params: [String: AnyObject]? = nil, headers: [String: String]? = nil, encoding: HTTPEncoding = .url, success: Success? = nil, failure: Failure? = nil) {
        execute(.patch, urlString: urlString, params: params, encoding: self.encoding(encoding), headers: headers, success: success, failure: failure)
    }
    
    public func put(_ urlString: String, params: [String: Any]? = nil, headers: [String: String]? = nil, encoding: HTTPEncoding = .url, success: Success? = nil, failure: Failure? = nil) {
        execute(.put, urlString: urlString, params: params, encoding: self.encoding(encoding), headers: headers, success: success, failure: failure)
    }
    
    public func delete(_ urlString: String, params: [String: AnyObject]? = nil, headers: [String: String]? = nil, encoding: HTTPEncoding = .url, success: Success? = nil, failure: Failure? = nil) {
        execute(.delete, urlString: urlString, params: params, encoding: self.encoding(encoding), headers: headers, success: success, failure: failure)
    }
    
}

extension HTTP {
    
    func isValid(statusCode: Int = 0) -> Bool {
        guard statusCode >= 200 && statusCode < 300 else {
            return false
        }
        return true
    }
    
    func handleError(response: DataResponse<Data>, urlString: String, method: HTTPMethod) -> Error {
        guard let data = response.data, let url = response.request?.url?.absoluteURL, let m = response.request?.httpMethod else {
            print("HTTP Error at \(method) \(urlString)")
            return NSError(domain:"Empty response", code:response.response?.statusCode ?? 0, userInfo:nil) as Error
        }
        
        guard let errorString = String(data: data, encoding: String.Encoding.utf8) else {
            print("HTTP Error at \(m) \(url)")
            return NSError(domain:"Server error", code:response.response?.statusCode ?? 0, userInfo:nil) as Error
        }
        
        return NSError(domain:errorString, code:response.response?.statusCode ?? 0, userInfo:nil) as Error
    }
}

