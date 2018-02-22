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

    let accountDefaultDesc = NSLocalizedString("Choose account", comment: "")
    let categoryDefaultDesc = NSLocalizedString("Category not specified", comment: "")
    let payerDefaultDesc = NSLocalizedString("Payer not specified", comment: "")
    let payeeDefaultDesc = NSLocalizedString("Payee not specified", comment: "")
    let tagDefaultDesc = NSLocalizedString("Tag not specified", comment: "")
    let noteDefaultDesc = NSLocalizedString("Additional note here", comment: "")

    // input-output
    var record: LTransaction?
    // input
    var createRecord: Bool = false
    var isSchedule: Bool = false

    var cancelButton: UIButton!
    var saveButton: UIButton!
    var deleteButton: UIButton!
    var titleButton: UIButton!

    var amountButton: UIButton!
    var dateButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarItems()
        createHeader()

        switch (record!.type) {
        case .EXPENSE:
            navigationController?.navigationBar.barTintColor = LTheme.Color.base_red
            amountButton!.setTitleColor(LTheme.Color.base_red, for: .normal)
        case .INCOME:
            navigationController?.navigationBar.barTintColor = LTheme.Color.base_green
            amountButton!.setTitleColor(LTheme.Color.base_green, for: .normal)
        default:
            navigationController?.navigationBar.barTintColor = LTheme.Color.base_blue
            amountButton!.setTitleColor(LTheme.Color.base_blue, for: .normal)

            payeeCell.isHidden = true
            tagCell.isHidden = true
            categoryLabel.text = accountDefaultDesc
        }
        titleButton.setTitle(LTransaction.getTypeString(record!.type), for: .normal)

        notesTextField.delegate = self

        if presentingViewController is NewAdditionTableViewController {
            let date = Date()

            let dayTimePeriodFormatter = DateFormatter()
            dayTimePeriodFormatter.dateStyle = .short

            let dateString = dayTimePeriodFormatter.string(from: date)
            dateButton!.setTitle(dateString, for: .normal)
        }

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
    }

    private func setupNavigationBarItems() {
        let BTN_W: CGFloat = 25
        let BTN_H: CGFloat = 25

        titleButton = UIButton(type: .custom)
        //titleButton.addTarget(self, action: #selector(self.onTitleClick), for: .touchUpInside)
        titleButton.setSize(w: 80, h: 30)
        navigationItem.titleView = titleButton

        cancelButton = UIButton(type: .system)
        cancelButton.addTarget(self, action: #selector(self.onCancelClick), for: .touchUpInside)
        cancelButton.setImage(#imageLiteral(resourceName: "ic_action_left").withRenderingMode(.alwaysOriginal), for: .normal)
        cancelButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20)
        cancelButton.setSize(w: BTN_W + 20, h: BTN_H)

        saveButton = UIButton(type: .system)
        saveButton.addTarget(self, action: #selector(self.onSaveClick), for: .touchUpInside)
        saveButton.setImage(#imageLiteral(resourceName: "ic_action_accept").withRenderingMode(.alwaysOriginal), for: .normal)
        saveButton.imageEdgeInsets = UIEdgeInsetsMake(0, 40, 0, 0)
        saveButton.setSize(w: BTN_W + 40, h: BTN_H)

        /*
         deleteButton = UIButton(type: .system)
         deleteButton.addTarget(self, action: #selector(self.onDeleteClick), for: .touchUpInside)
         deleteButton.setImage(#imageLiteral(resourceName: "ic_action_discard").withRenderingMode(.alwaysOriginal), for: .normal)
         deleteButton.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 15)
         deleteButton.setSize(w: BTN_W + 20, h: BTN_H)
         navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: cancelButton),
         UIBarButtonItem(customView: deleteButton)]
         */
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)

        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
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

        let valueBtn = UIButton(frame: CGRect(x: 1, y: 0, width: 0, height: 40))
        valueBtn.setTitle(NSLocalizedString("Unlimited", comment: ""), for: .normal)
        valueBtn.setTitleColor(LTheme.Color.base_text_color, for: .normal)
        valueBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        valueBtn.contentHorizontalAlignment = .right
        valueBtn.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 18)
        layout.addSubview(valueBtn)

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

        let intBtn = UIButton(frame: CGRect(x: 1, y: 0, width: 0, height: 40))
        intBtn.setTitle(NSLocalizedString("1", comment: ""), for: .normal)
        intBtn.setTitleColor(LTheme.Color.base_text_color, for: .normal)
        intBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        intBtn.contentHorizontalAlignment = .right
        intBtn.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 5)
        layout.addSubview(intBtn)

        let valueBtn = UIButton(frame: CGRect(x: 1, y: 0, width: 0, height: 40))
        valueBtn.setTitle(NSLocalizedString("month", comment: ""), for: .normal)
        valueBtn.setTitleColor(LTheme.Color.base_text_color, for: .normal)
        valueBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        valueBtn.contentHorizontalAlignment = .right
        valueBtn.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 18)
        layout.addSubview(valueBtn)

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
        amountButton.frame = CGRect(x: 0, y: 0, width: 80, height: BTN_H)

        dateButton = UIButton(type: .custom)
        dateButton.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 18)
        dateButton.titleLabel?.font = dateButton!.titleLabel?.font.withSize(fontsize - 2)
        dateButton.setTitleColor(UIColor.black, for: .normal)
        //dateButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: fontsize - 2)
        dateButton.contentHorizontalAlignment = .right
        dateButton.addTarget(self, action: #selector(self.onDateClick), for: .touchUpInside)
        dateButton.frame = CGRect(x: 0, y: 0, width: 80, height: BTN_H)

        let spacer = UIView(frame: CGRect(x: 1, y: 0, width: 0, height: 25))

        valueTimeHeader.addSubview(amountButton)
        valueTimeHeader.addSubview(spacer)
        valueTimeHeader.addSubview(dateButton)

        amountDateView.addSubview(valueTimeHeader)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0 || indexPath.row == 1) && !isSchedule {
            return 0
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if (indexPath.row == 0 || indexPath.row == 1) && !isSchedule {
            cell.isHidden = true
        }
        return cell
    }

    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func passNumberBack(_ caller: UIViewController, type: TypePassed) {
        if let _ = caller as? SelectAmountViewController {
            record!.amount = type.double
            amountButton.setTitle(String(format: "%.2lf", type.double), for: .normal)
            amountButton.sizeToFit()
        } else if let sv = caller as? SelectViewController {
            switch sv.selectType {
            case .ACCOUNT:
                record!.accountId = type.int64
                accountLabel.text = DBAccount.instance.get(id: type.int64)?.name
            case .ACCOUNT2:
                record!.accountId2 = type.int64
                categoryLabel.text = DBAccount.instance.get(id: type.int64)?.name
            case .CATEGORY:
                record!.categoryId = type.int64
                categoryLabel.text = DBCategory.instance.get(id: type.int64)?.name
            case .TAG:
                record!.tagId = type.int64
                tagLabel.text = DBTag.instance.get(id: type.int64)?.name
            case .PAYER: fallthrough
            case .PAYEE:
                record!.vendorId = type.int64
                payeeLabel.text = DBVendor.instance.get(id: type.int64)?.name
            default:
                LLog.e("\(self)", "unknown request type")
            }
        } else if let _ = caller as? DatePickerViewController {
            record!.timestamp = type.int64
            displayDateMs(type.int64)
        }

        updateSaveButtonState()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ChooseAccount")
            || (segue.identifier == "ChooseAmount")
            || (segue.identifier == "ChooseCategory")
            || (segue.identifier == "ChoosePayee")
            || (segue.identifier == "ChooseTag")
            || (segue.identifier == "ChooseDate") {

            let vc = segue.destination
            vc.modalPresentationStyle = UIModalPresentationStyle.popover
            vc.popoverPresentationController?.sourceView = self.view
            vc.popoverPresentationController?.sourceRect =
                CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            vc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
            vc.popoverPresentationController!.delegate = self
        }

        var color = LTheme.Color.base_blue
        switch (record!.type) {
        case .EXPENSE:
            color = LTheme.Color.base_red
        case .INCOME:
            color = LTheme.Color.base_green
        default:
            break;
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
            vc.initValue = record!.amount
            vc.color = color
        }  else if let vc = segue.destination as? DatePickerViewController {
            vc.delegate = self
            vc.initValue = record!.timestamp
            vc.color = color
        } else {
            LLog.d("\(self)", "unwinding")
        }
    }

    @objc func onAmountClick() {
        performSegue(withIdentifier: "ChooseAmount", sender: self)
    }

    @objc func onDateClick() {
        performSegue(withIdentifier: "ChooseDate", sender: self)
    }

    @objc func onSaveClick() {
        if isSchedule {
            navigationController?.navigationBar.barTintColor = LTheme.Color.top_bar_background
            navigationController?.popViewController(animated: true)
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
                        _ = LJournal.instance.addRecord(id: record!.id)
                    }
                    _ = navigationController?.popViewController(animated: true)
                } else {
                    if record!.type == .TRANSFER {
                        ret = DBTransaction.instance.update2(record!)
                    } else {
                        ret = DBTransaction.instance.update(record!)
                    }
                    if ret {
                        _ = LJournal.instance.updateRecord(id: record!.id)
                    }
                }
            }

            if presentingViewController is NewAdditionTableViewController {
                dismiss(animated: true, completion: nil)
            } else {
                performSegue(withIdentifier: "unwindToRecordList", sender: self)
            }
        }
    }

    @objc func onCancelClick() {
        navigationController?.navigationBar.barTintColor = LTheme.Color.top_bar_background

        if presentingViewController is NewAdditionTableViewController {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The RecordViewController is not inside a navigation controller.")
        }
    }

    /*
     @objc func onDeleteClick() {
     LLog.d("\(self)", "delete click")
     }
     */

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    private func updateSaveButtonState() {
        if (record!.type == .TRANSFER || record!.type == .TRANSFER_COPY) {
            if (accountLabel.text == "Choose Account") || (categoryLabel.text == "Choose Account") || (accountLabel.text == categoryLabel.text) {
                saveButton.isEnabled = false
            } else {
                saveButton.isEnabled = true
            }
        } else {
            //if (amountButton!.text == "Label") || (amountButton!.text == "0.0") || (accountLabel.text == "Choose Account") {
            //    saveButton.isEnabled = false
            //} else {
            saveButton.isEnabled = true
            //}
        }
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
