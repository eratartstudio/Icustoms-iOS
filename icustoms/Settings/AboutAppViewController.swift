//
//  AboutAppViewController.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 27/03/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit

class AboutAppViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    
    var compileDate: Date {
        let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "Info.plist"
        if let infoPath = Bundle.main.path(forResource: bundleName, ofType: nil),
            let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
            let infoDate = infoAttr[FileAttributeKey.creationDate] as? Date
        { return infoDate }
        return Date()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        let dateString = (formatter.string(from: compileDate) + " г.".localizedSafe).lowercased()
        
        label.text = "Версия ".localizedSafe + "\(version)" + "\nот ".localizedSafe + "\(dateString)" + "\nСборка ".localizedSafe + "\(build)"
    }
    
}
