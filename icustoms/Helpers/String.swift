//
//  String.swift
//  icustoms
//
//  Created by Danik's MacBook on 03/06/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import Foundation

extension String {
    public var localized: String? {
        return NSLocalizedString(self, comment: "") == self ? nil : NSLocalizedString(self, comment: "")
    }
    
    public var localizedSafe: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func maxLength(length: Int) -> String {
        var str = self
        let nsString = str as NSString
        if nsString.length >= length {
            str = nsString.substring(with:
                NSRange(
                    location: 0,
                    length: nsString.length > length ? length : nsString.length)
            )
        }
        return  str
    }
}

extension Collection where Indices.Iterator.Element == Index {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
