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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let mnc = self.myNavigationController {
            if let nvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddTableViewController")
                as? AddTableViewController {

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

        dismiss(animated: true, completion: nil)
    }
}
