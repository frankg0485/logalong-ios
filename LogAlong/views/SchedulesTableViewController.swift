//
//  SchedulesTableViewController.swift
//  LogAlong
//
//  Created by Michael Gao on 2/14/18.
//  Copyright © 2018 Swoag Technology. All rights reserved.
//

import UIKit

class SchedulesTableViewController: UITableViewController {

    //var schedules: [LScheduledTransaction]!
    var schedules: [LTransaction]!

    override func viewDidLoad() {
        super.viewDidLoad()
        schedules = DBTransaction.instance.getAll()

        setupNavigationBarItems()

        tableView.tableFooterView = UIView()
    }

    @objc func onCancelClick() {
        navigationController?.popViewController(animated: true)
    }

    //@objc func onSaveClick() {}

    private func setupNavigationBarItems() {
        let BTN_W: CGFloat = 25
        let BTN_H: CGFloat = 25

        let titleButton = UIButton(type: .custom)
        titleButton.setSize(w: 200, h: 30)
        titleButton.setTitle(NSLocalizedString("Scheduled Transactions", comment: ""), for: .normal)
        navigationItem.titleView = titleButton

        let cancelButton = UIButton(type: .system)
        cancelButton.addTarget(self, action: #selector(self.onCancelClick), for: .touchUpInside)
        cancelButton.setImage(#imageLiteral(resourceName: "ic_action_left").withRenderingMode(.alwaysOriginal), for: .normal)
        cancelButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20)
        cancelButton.setSize(w: BTN_W + 20, h: BTN_H)

        /*
        let saveButton = UIButton(type: .system)
        saveButton.addTarget(self, action: #selector(self.onSaveClick), for: .touchUpInside)
        saveButton.setImage(#imageLiteral(resourceName: "ic_action_accept").withRenderingMode(.alwaysOriginal), for: .normal)
        saveButton.imageEdgeInsets = UIEdgeInsetsMake(0, 40, 0, 0)
        saveButton.setSize(w: BTN_W + 40, h: BTN_H)*/

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        //navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)

        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedules.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsTableViewCell", for: indexPath) as! RecordsTableViewCell

        let record = schedules[indexPath.row]
        cell.showRecord(record)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddTableViewController")
            as! AddTableViewController
        let selectedRecord = schedules[indexPath.row]
        vc.record = selectedRecord

        self.navigationController?.pushViewController(vc, animated: true)
    }
}
