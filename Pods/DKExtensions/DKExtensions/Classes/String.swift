//
//  String.swift
//  DKExtensions
//
//  Created by Кузин Дмитрий on 27.03.2019.
//

import UIKit

public extension String {
    
    func capitalizingFirstLetter() -> String {
        let first = prefix(1).capitalized
        let other = dropFirst()
        return first + other
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    var isValidEmail: Bool {
        return range(of: "@") != nil && range(of: ".") != nil
    }
    
    var isValidPassword: Bool {
        return count >= 8
    }
    
    func clip(to index: Int) -> String {
        guard count > index && index > 0 else { return self }
        let stringIndex = self.index(self.startIndex, offsetBy: index)
        return "\(self.prefix(upTo: stringIndex))..."
    }
    
    // Localization
    
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }

    
    // Size
    
    func size(_ maxWidth: CGFloat, attributes: [NSAttributedString.Key: Any]) -> CGSize {
        let string = (self as NSString)
        guard string.length != 0 else {
            return .zero
        }
        
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byWordWrapping
        
        var attributesWithWordWrapping = attributes
        attributesWithWordWrapping[.paragraphStyle] = style
        
        let size = string.boundingRect(with: CGSize(width: maxWidth,
                                             height: .greatestFiniteMagnitude),
                                options: [.usesLineFragmentOrigin,.usesFontLeading],
                                attributes: attributesWithWordWrapping,
                                context: nil).size
        return CGSize(width: round(size.width),
                      height: round(size.height))
    }
    
    func height(_ maxWidth: CGFloat, attributes: [NSAttributedString.Key: Any]) -> CGFloat {
        return size(maxWidth, attributes: attributes).height
    }

    
    // Substring
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(to length: Int) -> String {
        guard self.count > length else { return self }
        let r = self.startIndex..<self.index(self.startIndex, offsetBy: length)
        return String(self[r])
    }
    
    func substring(from index: Int) -> String {
        guard index < self.count else { return self }
        let r = self.index(from: index) ..< self.endIndex
        return String(self[r])
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        let r = startIndex ..< endIndex
        return String(self[r])
    }
    
    static func generateRandom(_ length: Int = 10) -> String {
        let characters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var random: String = ""
        for _ in 0..<length {
            random += String(characters[characters.index(characters.startIndex, offsetBy: Int(arc4random_uniform(UInt32(characters.count))))])
        }
        return random
    }
    
}

