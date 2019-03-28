//
//  UIViewController.swift
//  DKExtensions
//
//  Created by Кузин Дмитрий on 27.03.2019.
//

import UIKit

public extension UIViewController {
    
    func showAlert(title: String?, message: String?, actions: [UIAlertAction]? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let actions = actions {
            actions.forEach { alert.addAction($0) }
        } else {
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        }
        present(alert, animated: true, completion: nil)
    }
    
    static func inNavigationStack() -> UIViewController {
        return UINavigationController(rootViewController: controller())
    }
    
    static func controller() -> Self {
        func controller<T>(_ type: T.Type) -> T {
            return storyboard().instantiateViewController(withIdentifier: storyboardIdentifier()) as! T
        }
        
        return controller(self)
    }
    
    class func storyboard() -> UIStoryboard {
        return UIStoryboard(name: storyboardName(), bundle: nil)
    }
    
    @objc
    class func storyboardName() -> String {
        return "Main"
    }
    
    class func storyboardIdentifier() -> String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    @objc
    @IBAction func back() {
        let popped = navigationController?.popViewController(animated: true)
        if popped == nil {
            dismiss()
        }
    }
    
    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        
    }
    
    func unwind() {
        self.performSegue(withIdentifier: "unwind", sender: self)
    }
    
}

public extension UIViewController {
    
    func present(_ classToPresent: UIViewController.Type, animated flag: Bool = true, completion: (() -> Swift.Void)? = nil) {
        present(classToPresent.controller(), animated: flag, completion: completion)
    }
    
    func push(_ viewController: UIViewController, animated: Bool = true) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func dismiss() {
        dismiss(animated: true)
    }
    
}

public extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
}
