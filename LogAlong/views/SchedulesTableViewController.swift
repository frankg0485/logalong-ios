//
//  SchedulesTableViewController.swift
//  LogAlong
//
//  Created by Michael Gao on 2/14/18.
//  Copyright © 2018 Swoag Technology. All rights reserved.
//

import UIKit

class SchedulesTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    let ADD_BUTTON_EXTRA_SPACE: CGFloat = 60

    var schedules: [LScheduledTransaction]!
    var addBtn: UIButton!
    var isVisible = false
    var isRefreshPending = false

    override func viewDidLoad() {
        super.viewDidLoad()
        schedules = DBScheduledTransaction.instance.getAll()

        setupNavigationBarItems()
        tableView.tableFooterView = UIView()

        LBroadcast.register(LBroadcast.ACTION_UI_DB_DATA_CHANGED,
                            cb: #selector(self.dbDataChanged),
                            listener: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        isVisible = true
        if (isRefreshPending) {
            refreshAll()
        }
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        isVisible = false
        super.viewDidDisappear(animated)
    }

    @objc func dbDataChanged(notification: Notification) -> Void {
        refreshAll()
    }

    @objc func onCancelClick() {
        navigationController?.popViewController(animated: true)
    }

    @objc func onAddClick() {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewAdditionTableViewController")
            as? NewAdditionTableViewController {

            vc.modalPresentationStyle = UIModalPresentationStyle.popover
            vc.popoverPresentationController?.sourceView = addBtn
            vc.popoverPresentationController?.sourceRect = CGRect(x: addBtn.bounds.midX + ADD_BUTTON_EXTRA_SPACE,
                                                                  y: addBtn.bounds.maxY, width: 0, height: 0)

            vc.popoverPresentationController?.permittedArrowDirections = .up
            vc.popoverPresentationController!.delegate = self

            vc.myNavigationController = self.navigationController
            vc.isSchedule = true

            //164 = 3 * 55 (cell height) - 1 (cell separator height): so to hide the last cell separator
            vc.preferredContentSize = CGSize(width: 135, height: 164)

            self.present(vc, animated: true, completion: nil)
        }
    }

    private func refreshAll() {
        if isVisible {
            isRefreshPending = false

            schedules = DBScheduledTransaction.instance.getAll()
            tableView.reloadData()
        } else {
            isRefreshPending = true
        }
    }

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

        addBtn = UIButton(type: .system)
        addBtn.addTarget(self, action: #selector(self.onAddClick), for: .touchUpInside)
        addBtn.setImage(#imageLiteral(resourceName: "ic_action_new").withRenderingMode(.alwaysOriginal), for: .normal)
        addBtn.setSize(w: BTN_W + ADD_BUTTON_EXTRA_SPACE, h: BTN_H)
        addBtn.imageEdgeInsets = UIEdgeInsetsMake(0, ADD_BUTTON_EXTRA_SPACE, 0, 0)

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addBtn)

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

        let record = LTransaction(trans: schedules[indexPath.row])
        record.timestamp = schedules[indexPath.row].scheduleTime
        cell.showRecord(record)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddViewController")
            as! AddViewController
        let selectedRecord = schedules[indexPath.row]
        vc.schedule = selectedRecord
        vc.isSchedule = true

        self.navigationController?.pushViewController(vc, animated: true)
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}
