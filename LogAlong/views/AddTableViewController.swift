//
//  AddTableViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 4/22/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit
import os.log

struct TypePassed {
    var double: Double = 0
    var int: Int = 0
    var int64: Int64 = 0
    var array64: [Int64]?
    var allSelected: Bool = false
}

class AddTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UITextFieldDelegate, FViewControllerDelegate {

    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var repeatCountView: UIView!
    @IBOutlet weak var repeatIntervalView: UIView!
    @IBOutlet weak var amountDateView: UIView!
    @IBOutlet weak var accountCell: UITableViewCell!
    @IBOutlet weak var categoryCell: UITableViewCell!
    @IBOutlet weak var payeeCell: UITableViewCell!
    @IBOutlet weak var tagCell: UITableViewCell!

    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var payeeLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var notesTextField: UITextField!

    var infoLabel: UILabel!
    let accountDefaultDesc = NSLocalizedString("Choose account", comment: "")
    let categoryDefaultDesc = NSLocalizedString("Category not specified", comment: "")
    let payerDefaultDesc = NSLocalizedString("Payer not specified", comment: "")
    let payeeDefaultDesc = NSLocalizedString("Payee not specified", comment: "")
    let tagDefaultDesc = NSLocalizedString("Tag not specified", comment: "")
    let noteDefaultDesc = NSLocalizedString("Additional note here", comment: "")

    // input-output
    var record: LTransaction!
    var schedule: LScheduledTransaction!

    // input
    var createRecord: Bool = false
    var isSchedule: Bool = false
    var isReadOnly: Bool = false
    var firstPopup = false

    var cancelButton: UIButton!
    var saveButton: UIButton!
    var saveButton2: UIButton!
    var deleteButton: UIButton!
    var titleButton: UIButton!

    var amountButton: UIButton!
    var dateButton: UIButton!

    var repeatCountButton: UIButton?
    var repeatIntervalButton: UIButton?
    var repeatUnitButton: UIButton?

    var origRecord: LTransaction!
    var origSchedule: LScheduledTransaction!
    var myNavigationController: UINavigationController?
    var myNavigationItem: UINavigationItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        if isSchedule {
            record = schedule
            origSchedule = LScheduledTransaction(schedule: schedule)
        } else if createRecord {
            loadTimestampValues()
        }

        origRecord = LTransaction(trans: record!)

        setupNavigationBarItems()
        createHeader()
        createFooter()

        switch (record!.type) {
        case .EXPENSE:
            myNavigationController?.navigationBar.barTintColor = LTheme.Color.base_red
            amountButton!.setTitleColor(LTheme.Color.base_red, for: .normal)

        case .INCOME:
            myNavigationController?.navigationBar.barTintColor = LTheme.Color.base_green
            amountButton!.setTitleColor(LTheme.Color.base_green, for: .normal)

        default:
            myNavigationController?.navigationBar.barTintColor = LTheme.Color.base_blue
            amountButton!.setTitleColor(LTheme.Color.base_blue, for: .normal)

            payeeCell.isHidden = true
            tagCell.isHidden = true
            categoryLabel.text = accountDefaultDesc
        }
        titleButton.setTitle(LTransaction.getTypeString(record!.type), for: .normal)

        notesTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        notesTextField.delegate = self

        amountButton.setTitle(String(record!.amount), for: .normal)
        amountButton.sizeToFit()

        if (record!.type == .EXPENSE || record!.type == .INCOME) {
            if let catName = DBCategory.instance.get(id: record!.categoryId)?.name {
                categoryLabel.text = (!catName.isEmpty) ? catName : categoryDefaultDesc
            } else {
                categoryLabel.text = categoryDefaultDesc
            }
            if let tagName = DBTag.instance.get(id: record!.tagId)?.name {
                tagLabel.text = (!tagName.isEmpty) ? tagName : tagDefaultDesc
            } else {
                tagLabel.text = tagDefaultDesc
            }

            var vendName = ""
            if let vname = DBVendor.instance.get(id: record!.vendorId)?.name {
                vendName = vname
            }
            if (record!.type == .INCOME) {
                payeeLabel.text = (!vendName.isEmpty) ? vendName : payerDefaultDesc
            } else {
                payeeLabel.text = (!vendName.isEmpty) ? vendName : payeeDefaultDesc
            }

            if let acntName = DBAccount.instance.get(id: record!.accountId)?.name {
                accountLabel.text = acntName
            } else {
                accountLabel.text = accountDefaultDesc
            }
        } else  {
            var acntName1 = accountDefaultDesc
            var acntName2 = accountDefaultDesc

            if (record!.type == .TRANSFER) {
                if let acntName = DBAccount.instance.get(id: record!.accountId)?.name {
                    acntName1 = acntName
                }
                if let acntName = DBAccount.instance.get(id: record!.accountId2)?.name {
                    acntName2 = acntName
                }
            } else {
                if let acntName = DBAccount.instance.get(id: record!.accountId)?.name {
                    acntName2 = acntName
                }
                if let acntName = DBAccount.instance.get(id: record!.accountId2)?.name {
                    acntName1 = acntName
                }
            }

            accountLabel.text = acntName1
            categoryLabel.text = acntName2
        }
        notesTextField.text = record!.note

        displayDateMs(record!.timestamp)
        updateSaveButtonState()

        if isSchedule {
            updateScheduleDisplay()
        }

        if createRecord && !isSchedule {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(
                withIdentifier: "SelectAmountViewController") as! SelectAmountViewController

            vc.delegate = self
            vc.oldValue = record!.amount
            vc.color = readyForPopover(vc)

            firstPopup = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.present(vc, animated: true, completion: nil)
            })
        }
    }

    private func loadTimestampValues() {
        if let recordValues = LPreferences.getLastSavedValues() {
            if ((Date().currentTimeMillis - recordValues["lastTimestamp"]!) >= 3600000) {
                clearLastSavedValues()
                return
            }

            if record.type == .TRANSFER {
                record.accountId = recordValues["transAccountId"] ?? 0
                record.accountId2 = recordValues["transAccountId2"] ?? 0
            } else {
                record.accountId = recordValues["accountId"] ?? 0
                //record.categoryId = recordValues["categoryId"] ?? 0
                //record.vendorId = recordValues["payeeId"] ?? 0
                //record.tagId = recordValues["tagId"] ?? 0
            }
            record.timestamp = (recordValues["date"] ?? 0) + 1
        }
    }

    private func saveTimestampValues() {
        var recordValues = LPreferences.getLastSavedValues() ?? [String : Int64]()

        if record.type == .TRANSFER {
            recordValues["transAccountId"] = record.accountId
            recordValues["transAccountId2"] = record.accountId2
        } else {
            recordValues["accountId"] = record.accountId
            //recordValues["categoryId"] = record.categoryId
            //recordValues["payeeId"] = record.vendorId
            //recordValues["tagId"] = record.tagId
        }
        recordValues["lastTimestamp"] = Date().currentTimeMillis
        recordValues["date"] = record.timestamp

        LPreferences.setLastSavedValues(recordValues)
    }

    private func clearLastSavedValues() {
        var values = [String : Int64]()
        values["accountId"] = 0
        //values["categoryId"] = 0
        //values["payeeId"] = 0
        //values["tagId"] = 0
        values["date"] = 0
        values["transAccountId"] = 0
        values["transAccountId2"] = 0
        values["lastTimestamp"] = 0

        LPreferences.setLastSavedValues(values)
    }

    private func setupNavigationBarItems() {
        let BTN_W: CGFloat = 25
        let BTN_H: CGFloat = 25

        titleButton = UIButton(type: .custom)
        //titleButton.addTarget(self, action: #selector(self.onTitleClick), for: .touchUpInside)
        titleButton.setSize(w: 80, h: 30)
        myNavigationItem.titleView = titleButton

        cancelButton = UIButton(type: .system)
        cancelButton.addTarget(self, action: #selector(self.onCancelClick), for: .touchUpInside)
        cancelButton.setImage(#imageLiteral(resourceName: "ic_action_left").withRenderingMode(.alwaysOriginal), for: .normal)
        cancelButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 60)
        cancelButton.setSize(w: BTN_W + 60, h: BTN_H)

        saveButton = UIButton(type: .system)
        saveButton.addTarget(self, action: #selector(self.onSaveClick), for: .touchUpInside)
        saveButton.setImage(#imageLiteral(resourceName: "ic_action_accept").withRenderingMode(.alwaysOriginal), for: .normal)
        saveButton.setImage(#imageLiteral(resourceName: "ic_action_accept_disabled").withRenderingMode(.alwaysOriginal), for: .disabled)

        saveButton.imageEdgeInsets = UIEdgeInsetsMake(0, 60, 0, 0)
        saveButton.setSize(w: BTN_W + 60, h: BTN_H)

        //if createRecord {
            myNavigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        //} else {
        //    let deleteButton = UIButton(type: .system)
        //    deleteButton.addTarget(self, action: #selector(self.onDeleteClick), for: .touchUpInside)
        //    deleteButton.setImage(#imageLiteral(resourceName: "ic_action_discard").withRenderingMode(.alwaysOriginal), for: .normal)
        //    deleteButton.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 15)
        //    deleteButton.setSize(w: BTN_W + 20, h: BTN_H)
        //    myNavigationItem.leftBarButtonItems = [UIBarButtonItem(customView: cancelButton),
        //                                         UIBarButtonItem(customView: deleteButton)]
        //}
        myNavigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)

        myNavigationController?.navigationBar.isTranslucent = false
        myNavigationController?.navigationBar.barStyle = .black
    }

    let entryHeight: CGFloat = 45
    let entryBottomMargin: CGFloat = 5

    private func createRepeatEntry() {
        let layout = HorizontalLayout(height: entryHeight)
        layout.layoutMargins.top = 0
        layout.layoutMargins.bottom = entryBottomMargin

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        label.textColor = LTheme.Color.gray_text_color
        label.text = NSLocalizedString("Repeat", comment: "")
        label.layoutMargins = UIEdgeInsetsMake(0, 16, 0, 0)
        layout.addSubview(label)

        repeatCountButton = UIButton(frame: CGRect(x: 1, y: 0, width: 0, height: 40))
        repeatCountButton!.addTarget(self, action: #selector(onRepeatCountClick), for: .touchUpInside)
        //repeatCountButton!.setTitle(NSLocalizedString("Unlimited", comment: ""), for: .normal)
        repeatCountButton!.setTitleColor(LTheme.Color.base_text_color, for: .normal)
        repeatCountButton!.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        repeatCountButton!.contentHorizontalAlignment = .right
        repeatCountButton!.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 18)
        layout.addSubview(repeatCountButton!)

        repeatCountView.addSubview(layout)
    }

    private func createRepeatIntervalEntry() {
        let layout = HorizontalLayout(height: entryHeight)
        layout.layoutMargins.top = 0
        layout.layoutMargins.bottom = entryBottomMargin

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        label.textColor = LTheme.Color.gray_text_color
        label.text = NSLocalizedString("Repeat every", comment: "")
        label.layoutMargins = UIEdgeInsetsMake(0, 16, 0, 0)
        layout.addSubview(label)

        repeatIntervalButton = UIButton(frame: CGRect(x: 1, y: 0, width: 0, height: 40))
        repeatIntervalButton!.addTarget(self, action: #selector(onRepeatIntervalClick), for: .touchUpInside)
        //repeatIntervalButton!.setTitle(NSLocalizedString("1", comment: ""), for: .normal)
        repeatIntervalButton!.setTitleColor(LTheme.Color.base_text_color, for: .normal)
        repeatIntervalButton!.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        repeatIntervalButton!.contentHorizontalAlignment = .right
        repeatIntervalButton!.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 10)
        layout.addSubview(repeatIntervalButton!)

        repeatUnitButton = UIButton(frame: CGRect(x: 1, y: 0, width: 0, height: 40))
        repeatUnitButton!.addTarget(self, action: #selector(onRepeatUnitClick), for: .touchUpInside)
        //repeatUnitButton!.setTitle(NSLocalizedString("month", comment: ""), for: .normal)
        repeatUnitButton!.setTitleColor(LTheme.Color.base_text_color, for: .normal)
        repeatUnitButton!.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        repeatUnitButton!.contentHorizontalAlignment = .right
        repeatUnitButton!.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 18)
        layout.addSubview(repeatUnitButton!)

        repeatIntervalView.addSubview(layout)
    }

    private func createHeader()
    {
        let BTN_H: CGFloat = 50
        let fontsize: CGFloat = 20

        if isSchedule {
            createRepeatEntry()
            createRepeatIntervalEntry()
        }

        let valueTimeHeader = HorizontalLayout(height: BTN_H)

        amountButton = UIButton(type: .custom)
        //amountButton.translatesAutoresizingMaskIntoConstraints = false
        amountButton.layoutMargins = UIEdgeInsetsMake(0, 16, 0, 0)
        amountButton.titleLabel?.font = amountButton!.titleLabel?.font.withSize(fontsize)
        amountButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: fontsize)
        amountButton.contentHorizontalAlignment = .left
        amountButton.addTarget(self, action: #selector(self.onAmountClick), for: .touchUpInside)
        amountButton.frame = CGRect(x: 4, y: 0, width: 0, height: BTN_H)

        dateButton = UIButton(type: .custom)
        dateButton.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 18)
        dateButton.titleLabel?.font = dateButton!.titleLabel?.font.withSize(fontsize - 2)
        dateButton.setTitleColor(UIColor.black, for: .normal)
        //dateButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: fontsize - 2)
        dateButton.contentHorizontalAlignment = .right
        dateButton.addTarget(self, action: #selector(self.onDateClick), for: .touchUpInside)
        dateButton.frame = CGRect(x: 4, y: 0, width: 0, height: BTN_H)

        let spacer = UIView(frame: CGRect(x: 2, y: 0, width: 0, height: 25))

        valueTimeHeader.addSubview(amountButton)
        valueTimeHeader.addSubview(spacer)
        valueTimeHeader.addSubview(dateButton)

        amountDateView.addSubview(valueTimeHeader)
    }

    private func createFooter() {
        let hl = HorizontalLayout(height: 30)

        let spacer = UIView(frame: CGRect(x: 1, y: 0, width: 0, height: 25))

        infoLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        infoLabel.textColor = LTheme.Color.light_gray_text_color
        infoLabel.text = ""
        infoLabel.font = UIFont.systemFont(ofSize: 11)
        infoLabel.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 16)
        infoLabel.contentMode = .right

        hl.addSubview(spacer)
        hl.addSubview(infoLabel)
        footerView.addSubview(hl)
        updateFooterInfo()
    }

    private func updateFooterInfo() {
        var txt: String

        let date = Date(milliseconds: record.timestampAccess)
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateStyle = .medium
        txt = dayTimePeriodFormatter.string(from: date)

        if record.by == LPreferences.getUserIdNum() || record.by <= 0 {
            txt += " " +  NSLocalizedString("by myself", comment: "")
        } else {
            if let name = LPreferences.getShareUserName(record.by) {
                txt += " " + NSLocalizedString("by ", comment: "") + name
            }
            else if let id = LPreferences.getShareUserId(record.by) {
                txt += " " + NSLocalizedString("by ", comment: "") + id
            }
        }
        infoLabel.text = txt
        infoLabel.sizeToFit()
    }

    private func updateScheduleDisplay() {
        repeatIntervalButton?.setTitle(String(schedule.repeatInterval), for: .normal)

        var txt = ""
        if schedule.repeatInterval > 1 {
            txt = (schedule.repeatUnit == LScheduledTransaction.REPEAT_UNIT_WEEK) ?
                 NSLocalizedString("weeks", comment: "") : NSLocalizedString("months", comment: "")
        } else {
            txt = (schedule.repeatUnit == LScheduledTransaction.REPEAT_UNIT_WEEK) ?
                NSLocalizedString("week", comment: "") : NSLocalizedString("month", comment: "")
        }
        repeatUnitButton?.setTitle(txt, for: .normal)

        if schedule.repeatCount == 0 {
            txt = NSLocalizedString("disabled", comment: "")
        } else if schedule.repeatCount == 1 {
            txt = NSLocalizedString("unlimited", comment: "")
        } else if schedule.repeatCount == 2 {
            txt = String(schedule.repeatCount - 1) + " " + NSLocalizedString("time", comment: "")
        } else {
            txt = String(schedule.repeatCount - 1) + " " + NSLocalizedString("times", comment: "")
        }
        repeatCountButton?.setTitle(txt, for: .normal)

        updateSaveButtonState()
    }

    private func isRowHidden(_ row: Int) -> Bool {
        if !isSchedule {
            if row == 0 || row == 1 {
                return true
            }
        }

        if record.type == .TRANSFER || record.type == .TRANSFER_COPY {
            if (row == 5 || row == 6) {
                return true
            }
        }
        return false
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isRowHidden(indexPath.row) {
            return 0
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if isRowHidden(indexPath.row) {
            cell.isHidden = true
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if (isSchedule && indexPath.row == 0) || (!isSchedule && indexPath.row == 2) {
            return .delete
        } else {
            return .none
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if .delete == editingStyle {
            if DBAccount.instance.get(id: record.accountId) == nil ||
                (record.type == .TRANSFER && DBAccount.instance.get(id: record.accountId2) == nil) {
                LLog.d("\(self)", "account no longer exists, commit action ignored")
                return onCancelClick()
            }

            if isSchedule {
                if DBScheduledTransaction.instance.remove(id: schedule.id) {
                    _ = LJournal.instance.deleteSchedule(gid: schedule.gid)
                }
            } else {
                var ret = false
                if record.type == .TRANSFER {
                    ret = DBTransaction.instance.remove2(id: record.id)
                } else {
                    ret = DBTransaction.instance.remove(id: record.id)
                }
                if ret {
                    _ = LJournal.instance.deleteRecord(gid: record.gid)
                }
            }
            onCancelClick()
        }
    }

    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let limitLength = 32
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= limitLength
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if let txt = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            record.note = txt
            updateSaveButtonState()
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let txt = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            record.note = txt
            updateSaveButtonState()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func passNumberBack(_ caller: UIViewController, type: TypePassed, okPressed: Bool) {
        if let _ = caller as? SelectAmountViewController {
            if !okPressed && firstPopup {
                myNavigationController?.navigationBar.barTintColor = LTheme.Color.top_bar_background
                myNavigationController?.popViewController(animated: true)
            } else {
                firstPopup = false

                if okPressed {
                    record!.amount = type.double

                    amountButton.setTitle(String(format: "%.2lf", type.double), for: .normal)
                    amountButton.sizeToFit()
                }
            }
        } else if let sv = caller as? SelectViewController {
            switch sv.selectType {
            case .ACCOUNT:
                record!.accountId = type.int64
                if let name = DBAccount.instance.get(id: type.int64)?.name {
                    accountLabel.text = name
                } else {
                    accountLabel.text = accountDefaultDesc
                }
            case .ACCOUNT2:
                record!.accountId2 = type.int64
                if let name = DBAccount.instance.get(id: type.int64)?.name {
                    categoryLabel.text = name
                } else {
                    categoryLabel.text = accountDefaultDesc
                }
            case .CATEGORY:
                record!.categoryId = type.int64
                if let name = DBCategory.instance.get(id: type.int64)?.name {
                    categoryLabel.text = name
                } else {
                    categoryLabel.text = categoryDefaultDesc
                }
            case .TAG:
                record!.tagId = type.int64
                if let name = DBTag.instance.get(id: (type.int64))?.name {
                    tagLabel.text = name
                } else {
                    tagLabel.text = tagDefaultDesc
                }
            case .PAYER:
                record!.vendorId = type.int64
                if let name = DBVendor.instance.get(id: type.int64)?.name {
                    payeeLabel.text = name
                } else {
                    payeeLabel.text = payerDefaultDesc
                }
            case .PAYEE:
                record!.vendorId = type.int64
                if let name = DBVendor.instance.get(id: type.int64)?.name {
                    payeeLabel.text = name
                } else {
                    payeeLabel.text = payeeDefaultDesc
                }
            default:
                LLog.e("\(self)", "unknown request type")
            }
        } else if let _ = caller as? DatePickerViewController {
            record!.timestamp = type.int64

            if isSchedule {
                let cdate = Date(milliseconds: record.timestamp)
                let calendar = Calendar.current
                var comp = calendar.dateComponents(in: calendar.timeZone, from: cdate)
                comp.hour = LScheduledTransaction.START_HOUR_OF_DAY
                comp.minute = 0
                comp.second = 0
                let date = calendar.date(from: comp)!
                if record.timestamp < date.currentTimeMillis {
                    record.timestamp = date.currentTimeMillis
                }
            }
            displayDateMs(type.int64)
        }

        updateSaveButtonState()
    }

    // MARK: - Navigation
    private func readyForPopover(_ vc: UIViewController) -> UIColor {
        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        vc.popoverPresentationController?.sourceView = self.view
        vc.popoverPresentationController?.sourceRect =
            CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        vc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
        vc.popoverPresentationController!.delegate = self

        var color = LTheme.Color.base_blue
        switch (record!.type) {
        case .EXPENSE:
            color = LTheme.Color.base_red
        case .INCOME:
            color = LTheme.Color.base_green
        default:
            break;
        }
        return color
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return !tableView.isEditing && !isReadOnly
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var color = LTheme.Color.base_blue
        if (segue.identifier == "ChooseAccount")
            || (segue.identifier == "ChooseAmount")
            || (segue.identifier == "ChooseCategory")
            || (segue.identifier == "ChoosePayee")
            || (segue.identifier == "ChooseTag")
            || (segue.identifier == "ChooseDate") {

            let vc = segue.destination
            color = readyForPopover(vc)
        }

        if let vc = segue.destination as? SelectViewController {
            if segue.identifier == "ChooseAccount" {
                if record!.type == .TRANSFER_COPY {
                    vc.selectType = .ACCOUNT2
                    vc.initValues = [record!.accountId2]
                } else {
                    vc.selectType = .ACCOUNT
                    vc.initValues = [record!.accountId]
                }
            } else if segue.identifier == "ChooseCategory" {
                if record!.type == .TRANSFER {
                    vc.selectType = .ACCOUNT2
                    vc.initValues = [record!.accountId2]
                } else if record!.type == .TRANSFER_COPY {
                    vc.selectType = .ACCOUNT
                    vc.initValues = [record!.accountId]
                } else {
                    vc.selectType = .CATEGORY
                    vc.initValues = [record!.categoryId]
                }
            } else if segue.identifier == "ChooseTag" {
                vc.selectType = .TAG
                vc.initValues = [record!.tagId]
            } else if segue.identifier == "ChoosePayee" {
                if (record!.type == .INCOME) {
                    vc.selectType = .PAYER
                } else {
                    vc.selectType = .PAYEE
                }
                vc.initValues = [record!.vendorId]
            }

            vc.delegate = self
            vc.color = color
        }  else if let vc = segue.destination as? SelectAmountViewController {
            vc.delegate = self
            vc.oldValue = record!.amount
            vc.color = color
        }  else if let vc = segue.destination as? DatePickerViewController {
            vc.delegate = self
            vc.initValue = record!.timestamp
            vc.color = color
        } else {
            LLog.d("\(self)", "unwinding")
        }
    }

    @objc func onRepeatCountClick() {
        if tableView.isEditing || isReadOnly {
            return
        }

        schedule.repeatCount += 1
        if schedule.repeatCount > 11 {
            schedule.repeatCount = 0
        }

        updateScheduleDisplay()
    }

    @objc func onRepeatIntervalClick() {
        if tableView.isEditing || isReadOnly {
            return
        }

        schedule.repeatInterval += 1
        if schedule.repeatInterval > 12 {
            schedule.repeatInterval = 1
        }
        updateScheduleDisplay()
    }

    @objc func onRepeatUnitClick() {
        if tableView.isEditing || isReadOnly {
            return
        }

        if schedule.repeatUnit == LScheduledTransaction.REPEAT_UNIT_MONTH {
            schedule.repeatUnit = LScheduledTransaction.REPEAT_UNIT_WEEK
        } else {
            schedule.repeatUnit = LScheduledTransaction.REPEAT_UNIT_MONTH
        }

        updateScheduleDisplay()
    }

    @objc func onAmountClick() {
        if tableView.isEditing || isReadOnly {
            return
        }

        performSegue(withIdentifier: "ChooseAmount", sender: self)
    }

    @objc func onDateClick() {
        if tableView.isEditing || isReadOnly {
            return
        }

        performSegue(withIdentifier: "ChooseDate", sender: self)
    }

    @objc func onSaveClick() {
        if tableView.isEditing || isReadOnly {
            return
        }

        if DBAccount.instance.get(id: record.accountId) == nil ||
            (record.type == .TRANSFER && DBAccount.instance.get(id: record.accountId2) == nil) {
            LLog.d("\(self)", "account no longer exists, save action ignored")
            return onCancelClick()
        }

        record.by = Int64(LPreferences.getUserIdNum())
        record.timestampAccess = Date().currentTimeMillis

        if isSchedule {
            let cdate = Date(milliseconds: record.timestamp)
            let calendar = Calendar.current
            var comp = calendar.dateComponents(in: calendar.timeZone, from: cdate)
            comp.hour = LScheduledTransaction.START_HOUR_OF_DAY
            comp.minute = 0
            comp.second = 0
            let date = calendar.date(from: comp)!
            record.timestamp = date.currentTimeMillis

            schedule.initNextTimeMs()

            if createRecord {
                if DBScheduledTransaction.instance.add(&schedule!) {
                    _ = LJournal.instance.addSchedule(schedule.id)
                }
            } else {
                if DBScheduledTransaction.instance.update(schedule) {
                    _ = LJournal.instance.updateSchedule(schedule.id)
                }
            }
        } else {
            var ret = false
            if record!.type == .TRANSFER_COPY {
                LLog.e("\(self)", "unexpected transfer copy")
            } else {
                if createRecord {
                    if record!.type == .TRANSFER {
                        ret = DBTransaction.instance.add2(&record!)
                    } else {
                        ret = DBTransaction.instance.add(&record!)
                    }
                    if ret {
                        _ = LJournal.instance.addRecord(record!.id)
                    }

                    saveTimestampValues()
                } else {
                    if record!.type == .TRANSFER {
                        ret = DBTransaction.instance.update2(record!, oldAmount: origRecord.amount)
                    } else {
                        ret = DBTransaction.instance.update(record!, oldAmount: origRecord.amount)
                    }
                    if ret {
                        _ = LJournal.instance.updateRecord(record!.id)
                    }
                }
            }
        }
        myNavigationController?.navigationBar.barTintColor = LTheme.Color.top_bar_background
        myNavigationController?.popViewController(animated: true)
    }

    @objc func onDeleteClick() {
        if tableView.isEditing || isReadOnly {
            return
        }

        tableView.setEditing(true, animated: true)
    }

    @objc func onCancelClick() {
        myNavigationController?.navigationBar.barTintColor = LTheme.Color.top_bar_background
        myNavigationController?.popViewController(animated: true)
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    private func isRecordValid() -> Bool {
        if record.amount <= 0 || record.accountId <= 0 {
            return false
        }

        if record.type == .TRANSFER && (record.accountId2 <= 0 || record.accountId2 == record.accountId) {
            return false
        }

        return true
    }

    private func isRecordChanged() -> Bool {
        if (record.accountId != origRecord.accountId || record.accountId2 != origRecord.accountId2 ||
            record.amount != origRecord.amount || record.timestamp != origRecord.timestamp ||
            record.note != origRecord.note || record.categoryId != origRecord.categoryId ||
            record.vendorId != origRecord.vendorId || record.tagId != origRecord.tagId) {
            return true
        }
        return false
    }

    private func isScheduleChanged() -> Bool {
        if isRecordChanged() {
            return true
        }
        if schedule.enabled != origSchedule.enabled || schedule.repeatInterval != origSchedule.repeatInterval ||
            schedule.repeatUnit != origSchedule.repeatUnit || schedule.repeatCount != origSchedule.repeatCount {
            return true
        }
        return false
    }

    private func updateSaveButtonState() {
        if isSchedule {
            saveButton.isEnabled = isRecordValid() && (createRecord || isScheduleChanged())
        } else {
            saveButton.isEnabled = isRecordValid() && (createRecord || isRecordChanged())
        }
        saveButton2.isEnabled = saveButton.isEnabled
    }

    private func displayDateMs(_ ms: Int64) {
        let date = Date(milliseconds: ms)
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateStyle = .medium
        let dateString = dayTimePeriodFormatter.string(from: date)
        dateButton.setTitle(dateString, for: .normal)
        //dateButton.titleLabel?.sizeToFit()
        dateButton.sizeToFit()
    }
}
