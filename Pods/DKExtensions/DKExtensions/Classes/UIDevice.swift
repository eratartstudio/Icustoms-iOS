//
//  UIDevice.swift
//  DKExtensions
//
//  Created by Кузин Дмитрий on 27.03.2019.
//

import UIKit

public enum ScreenSize {
    case i3_5
    case i4
    case i4_7
    case i5_5
    case unknown
}

public enum Scale: CGFloat, Comparable, Equatable {
    case x1 = 1.0
    case x2 = 2.0
    case x3 = 3.0
    case unknown = 0
}

public func ==(lhs: Scale, rhs: Scale) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

public func <(lhs: Scale, rhs: Scale) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

public func <=(lhs: Scale, rhs: Scale) -> Bool {
    return lhs.rawValue <= rhs.rawValue
}

public func >=(lhs: Scale, rhs: Scale) -> Bool {
    return lhs.rawValue >= rhs.rawValue
}

public func >(lhs: Scale, rhs: Scale) -> Bool {
    return lhs.rawValue > rhs.rawValue
}

public extension UIDevice {
    
    var screen: ScreenSize {
        let size = UIScreen.main.bounds.size
        let height = max(size.width, size.height)
        
        switch height {
        case 480:
            return .i3_5
        case 568:
            return .i4
        case 667:
            return scale == .x3 ? .i5_5 : .i4_7
        case 736:
            return .i5_5
        default:
            return .unknown
        }
    }
    
    var scale: Scale {
        let scale = UIScreen.main.scale
        
        switch scale {
        case 1.0:
            return .x1
        case 2.0:
            return .x2
        case 3.0:
            return .x3
        default:
            return .unknown
        }
    }
    
}
