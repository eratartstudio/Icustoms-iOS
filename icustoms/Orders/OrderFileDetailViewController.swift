//
//  OrderFileDetailViewController.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 09/04/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit
import SVProgressHUD

class OrderFileDetailViewController: UIViewController {
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var filesCount: Int = 0
    var currentIndex: Int = 0
    
    var file: File!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "\(currentIndex + 1) из \(filesCount)"
        nameLabel.text = file.number
        descriptionLabel.text = file.name
        sizeLabel.text = printSizeFile(Int64(file.fileSize))
        dateLabel.text = Date.from(string: file.date, format: "yyyy-MM-dd'T'HH:mm:ssZZZ").string(with: "dd.MM.yyyy HH:mm:ss")
        typeLabel.text = file.mimeType
    }
    
    @IBAction func shareFileAction() {
        SVProgressHUD.show()
        API.default.downloadFiles(file.id, { data in
            SVProgressHUD.dismiss()
            let filename = self.file.name + "." + self.file!.fileExtension!
            let fileToShare: FileHandle? = FileHandle(forWritingAtPath: filename)
            fileToShare?.write(data)
            fileToShare?.closeFile()
            let activityViewController = UIActivityViewController(activityItems: [fileToShare!], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        }) { (error, statusCode) in
            SVProgressHUD.dismiss()
            self.showAlert("Ошибка".localizedSafe, message: "Невозможно загрузить файлы".localizedSafe)
            print("\(error)")
        }
    }
    
    public var kilobytes: Double {
        return Double(file.fileSize) / 1_024
    }
    
    public var megabytes: Double {
        return kilobytes / 1_024
    }
    
    public var gigabytes: Double {
        return megabytes / 1_024
    }
    
    func printSizeFile(_ size: Int64) -> String {
        switch size {
        case 0..<1_024:
            return "\(file.fileSize) bytes"
        case 1_024..<(1_024 * 1_024):
            return "\(String(format: "%.2f", kilobytes)) kb"
        case 1_024..<(1_024 * 1_024 * 1_024):
            return "\(String(format: "%.2f", megabytes)) mb"
        case (1_024 * 1_024 * 1_024)...Int64.max:
            return "\(String(format: "%.2f", gigabytes)) gb"
        default:
            return "\(file.fileSize) bytes"
        }
    }
    
}
