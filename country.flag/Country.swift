//
//  CountryFlag.swift
//  country.flag
//
//  Created by Dmitry Kuzin on 19/12/2018.
//  Copyright © 2018 Dmitry Kuzin. All rights reserved.
//

import Foundation

struct CountryItem: Decodable {
    let name: String
    let dial_code: String
    let code: String
}

public class Country {
    
    public static let current = Country()
    
    public func phoneCode() -> String? {
        guard let code = Locale.current.regionCode else { return nil }
        let countries = self.countries()
        let country = countries.filter { $0.code == code }.first
        return country?.dial_code
    }
    
    public func name() -> String? {
        guard let code = Locale.current.regionCode else { return nil }
        let countries = self.countries()
        let country = countries.filter { $0.code == code }.first
        return country?.name
    }
    
    public static func countryPhoneCode(for code: String) -> String? {
        let countries = current.countries()
        let country = countries.filter { $0.code.uppercased() == code.uppercased() }.first
        return country?.dial_code
    }
    
    public static func countryName(for code: String) -> String? {
        let countries = current.countries()
        let country = countries.filter { $0.code.uppercased() == code.uppercased() }.first
        return country?.name
    }
    
    public func codes() -> [String] {
        return countries().map { $0.dial_code }
    }
    
    func countries() -> [CountryItem] {
        guard let url = Bundle.CountryIcons.url(forResource: "countryCodes", withExtension: "json") else { return [] }
        do {
            let data = try Data(contentsOf: url)
            let countries = try JSONDecoder().decode([CountryItem].self, from: data)
            return countries
        } catch {
            print(error)
        }
        return []
    }
    
    
    
}

extension Bundle {
    static public var CountryIcons = countryFlag()

    static public func countryFlag() -> Bundle {
        let bundle = Bundle(for: Country.self)

        if let path = bundle.path(forResource: "country_flag", ofType: "bundle") {
            return Bundle(path: path)!
        } else {
            return bundle
        }
    }
}
