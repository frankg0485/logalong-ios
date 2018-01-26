//
//  NewAdditionTableViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 6/9/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class NewAdditionTableViewController: UITableViewController {

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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let secondViewController = segue.destination as? UINavigationController {
            if let nextViewController = secondViewController.topViewController as? AddTableViewController {
                let record = LTransaction()
                nextViewController.record = record
                switch (segue.identifier ?? "") {
                case "AddExpense":
                    record.type = .EXPENSE

                case "AddIncome":
                    record.type = .INCOME

                case "AddTransfer":
                    record.type = .TRANSFER

                default:
                    fatalError()
                }
            }
        }
    }

}
