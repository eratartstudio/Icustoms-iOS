//
//  FileTableCell.swift
//  icustoms
//
//  Created by Danik's MacBook on 22/09/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit

class FileTableCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    var file: File? {
        didSet {
            updateContent()
        }
    }
    
    private func updateContent() {
        guard let file = file else { return }
        nameLabel.text = file.name
        descriptionLabel.text = Date.from(string: file.date, format: "yyyy-MM-dd'T'HH:mm:ssZZZ").string(with: "dd.MM.yyyy HH:mm:ss")
        typeLabel.text = file.fileExtension?.uppercased()
    }
}
