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
        view.backgroundColor = LTheme.Color.default_bgd_color
        tableView.backgroundColor = LTheme.Color.default_bgd_color
        setupSwipe()
        setupNavigationBarItems()

        let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        versionLabel.text = appVersionString
        versionLabel.sizeToFit()

        //tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setupNavigationBarItems() {
        let titleBtn = UIButton(type: .custom)
        titleBtn.setSize(w: 80, h: 30)
        titleBtn.setTitle(NSLocalizedString("Settings", comment: ""), for: .normal)
        navigationItem.titleView = titleBtn

        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = LTheme.Color.top_bar_background
        navigationController?.navigationBar.barStyle = .black
    }

    @objc func handleGestureRight(_ gesture: UIGestureRecognizer) {
        tabBarController?.selectedIndex = 1
    }

    private func setupSwipe() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGestureRight(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = LTheme.Color.default_bgd_color
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
