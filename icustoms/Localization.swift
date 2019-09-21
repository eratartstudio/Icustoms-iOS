//
//  Localization.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 27/05/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let localizationDidChange = Notification.Name("localizationDidChange")
}

protocol Localizable: class {
    func localize(_ locale: Localization)
}

enum LocalizationName: String {
    case en = "en_US"
    case ru = "ru_RU"
    case ch = "zh_Hans_SG"
    static let all: [LocalizationName] = [.en, .ru, .ch]
}

class Localization {
    
    private var dict: [String: String] = [:]
    
    static func current() -> Localization {
        let deviceLocale = Locale.current.identifier
        let lang = LocalizationName.all.filter { $0.rawValue.lowercased() == deviceLocale.lowercased() }.first
        print(deviceLocale)
        if let lang = lang {
            return Localization(name: lang)
        } else {
            return Localization(name: .en)
        }
    }
    
    init(name: LocalizationName) {
        let content = getContent(name)
        dict = [:]
        var rows = content.components(separatedBy: ";").map { $0.replacingOccurrences(of: "\n", with: "") }
        rows.removeLast()
        rows.forEach {
            guard let key = $0.components(separatedBy: "=").first, let value = $0.components(separatedBy: "=").last else { return }
            dict[key] = value.replacingOccurrences(of: "*/", with: "\n")
        }
    }
    
    private func getContent(_ name: LocalizationName) -> String {
        guard let url = Bundle.main.url(forResource: name.rawValue, withExtension: nil) else { return "" }
        do {
            return try String(contentsOf: url)
        } catch {
            print(error)
            return ""
        }
    }
    
    func get(_ key: LocalizationKey) -> String {
        print(dict[key.rawValue] ?? "")
        return dict[key.rawValue] ?? ""
    }
    
}

//Keys
enum LocalizationKey: String {
    case error
    case authorization_failed
    case enter_sms_code
    case select_account_login
    case cancel
    case you_can_request_code_again
    case failed_load_order
    case search
    case close
    case completed_orders
    case paid_percent
    case scored
    case score_order
    case review_after_order
    case submit_feedback
    case submit
    case feedback_submission_failed
    case order_number_copied
    case track_not_specified
    case file_not_exist
    case failed_to_load_file
    case all
    case created
    case in_progress_analysis
    case in_progress_declaration
    case order_assigned_declaration
    case declaration_under_verification
    case issuing_declaration
    case declaration_under_inspection
    case conditional_release
    case completed
    case failed_to_load_remains
    case remains_relevant
    case advance_payment
    case duty
    case failed_to_load_balance
    case january
    case febrary
    case march
    case april
    case may
    case june
    case july
    case august
    case september
    case october
    case november
    case december
    case failed_to_display_data
    case failed_to_load_data
}
