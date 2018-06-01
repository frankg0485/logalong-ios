//
//  NewAdditionTableViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 6/9/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class NewAdditionTableViewController: UITableViewController {
    var myNavigationController: UINavigationController!
    var isSchedule: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = LTheme.Color.default_bgd_color
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewWillAppear(_ animated: Bool) {
        view.superview?.layer.borderColor = UIColor.white.cgColor
        view.superview?.layer.borderWidth = 1

        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1:
            cell.backgroundColor = LTheme.Color.income_selector_normal
        case 2:
            cell.backgroundColor = LTheme.Color.transfer_selector_normal
        default:
            cell.backgroundColor = LTheme.Color.expense_selector_normal
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let mnc = self.myNavigationController {
            if let nvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddViewController")
                as? AddViewController {

                var record: LTransaction?

                nvc.createRecord = true
                nvc.isSchedule = isSchedule
                if isSchedule {
                    nvc.schedule = LScheduledTransaction()
                    record = nvc.schedule
                } else {
                    record = LTransaction()
                    nvc.record = record
                }

                switch indexPath.row {
                case 1: record!.type = .INCOME
                case 2: record!.type = .TRANSFER
                case 0: fallthrough
                default:
                     record!.type = .EXPENSE
                }
                mnc.pushViewController(nvc, animated: true)
            }
        }
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
