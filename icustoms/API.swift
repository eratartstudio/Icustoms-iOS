//
//  API.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 22/03/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import Foundation
import Alamofire

class API {
    
    static let `default` = API()
    
    private func request<T: Decodable>(_ url: String, method: HTTPMethod, parameters: Parameters?, headers: HTTPHeaders?, _ completion: @escaping (T?) -> Void) {
        
        Alamofire.request(url, method: method, parameters: parameters, headers: headers).responseData { (response) in
            guard let data = response.data else {
                completion(nil)
                return
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
