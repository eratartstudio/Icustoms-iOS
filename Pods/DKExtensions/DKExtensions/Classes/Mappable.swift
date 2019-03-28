//
//  Mappable.swift
//  DKExtensions
//
//  Created by Кузин Дмитрий on 27.03.2019.
//

import UIKit

public typealias JSONResponse = [String : Any]

public protocol EntityDecodable {
    
    associatedtype Model where Model: Decodable
    
    static func parse(json: JSONResponse) -> Model?
    static func decode(_ model: Model, from decoder: Decoder) throws
    
}

public extension EntityDecodable {
    
    static func parse(json: JSONResponse) -> Model? {
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            return try JSONDecoder().decode(Model.self, from: data)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
}

public protocol EntityEncodable {
    
    associatedtype Model where Model: Encodable
    
    static func encode(_ model: Model, from encoder: Encoder) throws
    
}
