//
//  UIView.swift
//  DKExtensions
//
//  Created by Кузин Дмитрий on 27.03.2019.
//

import UIKit

public extension NSObject {
    
    static func fromXib(_ nib: String? = nil, owner: AnyObject? = nil) -> Self {
        let nibName = nib ?? self.nibName()
        
        func fromXib<T>(_ type: T.Type) -> T {
            return Bundle.main.loadNibNamed(nibName, owner: owner, options: nil)!.first as! T
        }
        
        return fromXib(self)
    }
    
    static func nib() -> UINib {
        return UINib(nibName: nibName(), bundle: nil)
    }
    
    static func nibName() -> String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
}

public extension UINib {
    
    func register(in table: UITableView, for identifier: String? = nil) {
        table.register(self, forCellReuseIdentifier: identifier ?? type(of: self).nibName())
    }
    
}

public extension UITableView {
    
    func dequeueReusableCell<T: UITableViewCell>(_ type: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: String(describing: type), for: indexPath) as! T
    }
    
}
