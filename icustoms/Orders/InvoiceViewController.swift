//
//  File.swift
//  icustoms
//
//  Created by Danik's MacBook on 22/09/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit
import SVProgressHUD
import WebKit

class InvoiceViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    var data: Data!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        DispatchQueue.global().async {
            let timestamp = Date().timestamp
            var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            url.appendPathComponent("\(timestamp)")
            do {
                try self.data.write(to: url)
                print(url)
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.webView.load(self.data, mimeType: "application/pdf", textEncodingName: "", baseURL: url)
                }
            } catch {
                print(error)
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: false)
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    @IBAction func shareData() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("invoice-\(NSDate().timeIntervalSince1970).pdf")
        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print(error)
        }
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
}
