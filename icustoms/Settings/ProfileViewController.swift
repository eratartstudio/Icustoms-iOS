//
//  ProfileViewController.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 02/04/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit

class ProfileViewController: UITableViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var fioLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    var profile: Profile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        API.default.profile(success: { [weak self] (profile) in
            self?.profile = profile
            self?.tableView.reloadData()
            self?.updateContent()
        }) { [weak self] (error, statusCode) in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    func updateContent() {
        guard profile != nil else { return }
        idLabel.text = "id \(profile?.id ?? 0)"
        fioLabel.text = "\(profile.lastName ?? "")" + " " + "\(profile.firstName ?? "")" + " " + "\(profile.middleName ?? "")"
        phoneLabel.text = profile.phone ?? ""
        companyLabel.text = profile.company ?? ""
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        //guard profile != nil else { return 0 }
        return 4
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            Database.default.deleteUser()
            UIApplication.shared.keyWindow?.rootViewController = Storyboard.Authorization.initialViewController
        }
    }
}
