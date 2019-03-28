//
//  Storyboards.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 22/03/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit

struct Storyboard {
 
    struct Authorization {
        static let name: String = "Authorization"
        static var instance: UIStoryboard {
            return UIStoryboard(name: name, bundle: nil)
        }
        static var initialViewController: UIViewController? {
            return instance.instantiateInitialViewController()
        }
    }
    
    struct Main {
        static let name: String = "Main"
        static var instance: UIStoryboard {
            return UIStoryboard(name: name, bundle: nil)
        }
        static var initialViewController: UIViewController? {
            return instance.instantiateInitialViewController()
        }
    }
    
}
