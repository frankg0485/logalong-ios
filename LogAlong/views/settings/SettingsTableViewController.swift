//
//  SettingsTableViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 9/24/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var versionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarController?.tabBar.isOpaque = true

        let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        versionLabel.text = appVersionString
        versionLabel.sizeToFit()

        tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nvc = segue.destination as? AccountsTableViewController {
            switch(segue.identifier ?? "") {
            case "ManageAccounts":
                nvc.listType = .ACCOUNT
            case "ManageCategories":
                nvc.listType = .CATEGORY
            case "ManageVendors":
                nvc.listType = .VENDOR
            case "ManageTags":
                nvc.listType = .TAG
            default: break
            }
        }
    }
}
