//
//  AddViewController.swift
//  LogAlong
//
//  Created by Michael Gao on 5/13/18.
//  Copyright © 2018 Swoag Technology. All rights reserved.
//

import UIKit

class AddViewController: UIViewController {
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var containterView: UIView!

    // input-output
    var record: LTransaction!
    var schedule: LScheduledTransaction!

    // input
    var createRecord: Bool = false
    var isSchedule: Bool = false
    var isReadOnly: Bool = false
    var firstPopup = false

    var saveButton: UIButton!
    var addTableVC: AddTableViewController?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let vc as AddTableViewController:
            if isSchedule {
                record = schedule
            }
            setupBottomBar()

            vc.record = record
            vc.schedule = schedule
            vc.createRecord = createRecord
            vc.isSchedule = isSchedule
            vc.isReadOnly = isReadOnly
            vc.firstPopup = firstPopup
            vc.myNavigationController = navigationController
            vc.myNavigationItem = navigationItem

            vc.saveButton2 = saveButton

            addTableVC = vc
        default:
            break;
        }
    }

    @objc func onCancelClick() {
        addTableVC?.onCancelClick()
    }

    @objc func onSaveClick() {
        addTableVC?.onSaveClick()
    }

    @objc func onDeleteClick() {
        addTableVC?.onDeleteClick()
    }

    private func setupBottomBar() {
        let BTN_W: CGFloat = 100
        let BTN_H: CGFloat = 35
        let BTN_MARGIN: CGFloat = 12
        let BTN_SIZE: CGFloat = 25

        var color = LTheme.Color.base_blue
        switch (record!.type) {
        case .EXPENSE:
            color = LTheme.Color.base_red
        case .INCOME:
            color = LTheme.Color.base_green
        default:
            break;
        }

        let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: BTN_W, height: BTN_H))
        cancelButton.addTarget(self, action: #selector(self.onCancelClick), for: .touchUpInside)
        cancelButton.setImage(#imageLiteral(resourceName: "ic_action_left").withRenderingMode(.alwaysOriginal), for: .normal)
        cancelButton.imageEdgeInsets = UIEdgeInsets(top: (BTN_H - BTN_SIZE)/2, left: BTN_MARGIN,
                                                    bottom: (BTN_H - BTN_SIZE)/2, right: BTN_W - BTN_SIZE - BTN_MARGIN)

        saveButton = UIButton(frame: CGRect(x: 0, y: 0, width: BTN_W, height: BTN_H))
        saveButton.addTarget(self, action: #selector(self.onSaveClick), for: .touchUpInside)
        saveButton.setImage(#imageLiteral(resourceName: "ic_action_accept").withRenderingMode(.alwaysOriginal), for: .normal)
        saveButton.setImage(#imageLiteral(resourceName: "ic_action_accept_disabled").withRenderingMode(.alwaysOriginal), for: .disabled)
        saveButton.imageEdgeInsets = UIEdgeInsets(top: (BTN_H - BTN_SIZE)/2, left: BTN_W - BTN_SIZE - BTN_MARGIN,
                                                  bottom: (BTN_H - BTN_SIZE)/2, right: BTN_MARGIN)

        let spacer1 = UIView(frame: CGRect(x: 1, y: 0, width: 0, height: BTN_H))
        let spacer2 = UIView(frame: CGRect(x: 1, y: 0, width: 0, height: BTN_H))

        let layout = HorizontalLayout(height: BTN_H)
        layout.addSubview(cancelButton)
        layout.addSubview(spacer1)
        if !createRecord {
            let deleteButton = UIButton(frame: CGRect(x: 0, y: 0, width: 55, height: BTN_H))
            deleteButton.addTarget(self, action: #selector(self.onDeleteClick), for: .touchUpInside)
            deleteButton.setImage(#imageLiteral(resourceName: "ic_action_discard").withRenderingMode(.alwaysOriginal), for: .normal)
            deleteButton.imageEdgeInsets = UIEdgeInsets(top: (BTN_H - BTN_SIZE)/2, left: (55 - BTN_SIZE)/2,
                                                        bottom: (BTN_H - BTN_SIZE)/2, right: (55 - BTN_SIZE)/2)
            layout.addSubview(deleteButton)
            layout.addSubview(spacer2)
        }
        layout.addSubview(saveButton)
        layout.backgroundColor = color.withAlphaComponent(0.75)

        bottomBar.addSubview(layout)
    }
}
