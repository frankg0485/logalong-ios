//
//  CreateViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 8/15/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

struct NameWithId {
    var name: String = ""
    var id: Int64 = 0
}

class CreateViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    //var creation: NameWithId? = NameWithId(name: "", id: 0)
    var delegate: FPassCreationBackDelegate!
    var createType: SelectType!
    var isCreate: Bool = true
    var entryName: String = ""
    var optionalSwitchOrig: Bool = true
    var payerSwitchOrig: Bool = true
    var account: LAccount?
    var category: LCategory?
    var vendor: LVendor?
    var tag: LTag?

    @IBOutlet weak var payerSwitch: UISwitch!
    @IBOutlet weak var payerLabel: UILabel!
    @IBOutlet weak var optionalLabel: UILabel!
    @IBOutlet weak var optionalSwitch: UISwitch!
    @IBOutlet weak var newLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var okButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize.width = LTheme.Dimension.popover_width
        self.preferredContentSize.height = LTheme.Dimension.popover_height_small

        optionalLabel.textColor = LTheme.Color.dark_gray_text_color
        payerLabel.textColor = LTheme.Color.dark_gray_text_color

        nameTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        nameTextField.autocorrectionType = .no
        nameTextField.autocapitalizationType = .none
        nameTextField.becomeFirstResponder()

        switch (createType!) {
        case .ACCOUNT: fallthrough
        case .ACCOUNT2:
            if isCreate {
                newLabel.text = NSLocalizedString("New Account", comment: "")
                nameTextField.placeholder = NSLocalizedString("Name", comment: "")
                account = LAccount()
                account?.showBalance = true
            } else {
                newLabel.text = NSLocalizedString("Edit Account", comment: "")
                account = DBAccount.instance.get(name: entryName)
                nameTextField.placeholder = account?.name
            }
        case .CATEGORY:
            if isCreate {
                newLabel.text = NSLocalizedString("New Category", comment: "")
                nameTextField.placeholder = NSLocalizedString("Category : Sub-category", comment: "")
                category = LCategory()
            } else {
                newLabel.text = NSLocalizedString("Edit Category", comment: "")
                category = DBCategory.instance.get(name: entryName)
                nameTextField.placeholder = category?.name
            }
        case .PAYEE:
            newLabel.text = NSLocalizedString("New Payee", comment: "")
            nameTextField.placeholder = NSLocalizedString("Name", comment: "")
            vendor = LVendor()
            vendor?.type = .PAYEE
        case .PAYER:
            newLabel.text = NSLocalizedString("New Payer", comment: "")
            nameTextField.placeholder = NSLocalizedString("Name", comment: "")
            vendor = LVendor()
            vendor?.type = .PAYER
        case .VENDOR:
            if isCreate {
                newLabel.text = NSLocalizedString("New Payee/Payer", comment: "")
                nameTextField.placeholder = NSLocalizedString("Name", comment: "")
                vendor = LVendor()
                vendor?.type = .PAYEE_PAYER
            } else {
                newLabel.text = NSLocalizedString("Edit Payee/Payer", comment: "")
                vendor = DBVendor.instance.get(name: entryName)
                nameTextField.placeholder = vendor?.name
            }
        case .TAG:
            if isCreate {
                newLabel.text = NSLocalizedString("New Tag", comment: "")
                nameTextField.placeholder = NSLocalizedString("Name", comment: "")
                tag = LTag()
            } else {
                newLabel.text = NSLocalizedString("Edit Tag", comment: "")
                tag = DBTag.instance.get(name: entryName)
                nameTextField.placeholder = tag?.name
            }
        case .TYPE:
            LLog.e("\(self)", "Unexpected: type select in CreateViewController")
        }

        setOptionalDisplay()
        checkOkButtonState()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        view.superview?.layer.borderColor = LTheme.Color.base_orange.cgColor
        view.superview?.layer.borderWidth = 1

        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func okButtonClicked(_ sender: UIButton) {
        if let new_name = nameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
            var name = new_name
            if name.isEmpty { // OK is clicked due to other change from switch
                name = entryName
            }

            switch (createType!) {
            case .ACCOUNT: fallthrough
            case .ACCOUNT2:
                account!.name = name
                if isCreate {
                    if DBAccount.instance.add(&account!) {
                        DBAccountBalance.updateAccountBalance(id: account!.id, amount: 0, timestamp: Date().currentTimeMillis)
                        _ = LJournal.instance.addAccount(account!.id)
                    }
                } else {
                    if DBAccount.instance.update(account!) {
                        _ = LJournal.instance.updateAccount(account!.id)
                    }
                }
            case .CATEGORY:
                category!.name = name
                if isCreate {
                    if DBCategory.instance.add(&category!) {
                        _ = LJournal.instance.addCategory(category!.id)
                    }
                } else {
                    if DBCategory.instance.update(category!) {
                        _ = LJournal.instance.updateCategory(category!.id)
                    }
                }
            case .PAYER: fallthrough
            case .PAYEE: fallthrough
            case .VENDOR:
                vendor!.name = name
                if isCreate {
                    if DBVendor.instance.add(&vendor!) {
                        _ = LJournal.instance.addVendor(vendor!.id)
                    }
                } else {
                    if DBVendor.instance.update(vendor!) {
                        _ = LJournal.instance.updateVendor(vendor!.id)
                    }
                }
            case .TAG:
                tag!.name = name
                if isCreate {
                    if DBTag.instance.add(&tag!) {
                        _ = LJournal.instance.addTag(tag!.id)
                    }
                } else {
                    if DBTag.instance.update(tag!) {
                        _ = LJournal.instance.updateTag(tag!.id)
                    }
                }
            case .TYPE:
                LLog.e("\(self)", "Unexpected: type select in CreateViewController")
            }
            delegate.creationCallback(created: true)
        }
        dismiss(animated: true, completion: nil)
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        checkOkButtonState()
    }

    /*func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }*/

    func textFieldDidEndEditing(_ textField: UITextField) {
        checkOkButtonState()
    }

    private func checkOkButtonState() {
        var state = false
        var name = ""
        if let new_name = nameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
            name = new_name
            if name.isEmpty {
                //rename/edit entry, but there's no user input yet detected
                name = entryName
            }
            if name.count > 1 {
                switch (createType) {
                case .ACCOUNT: fallthrough
                case .ACCOUNT2:
                    if let _ = DBAccount.instance.get(name: name) {
                        state = false
                    } else {
                        state = true
                    }
                case .CATEGORY:
                    if let _ = DBCategory.instance.get(name: name) {
                        state = false
                    } else {
                        state = true
                    }
                case .PAYER: fallthrough
                case .PAYEE: fallthrough
                case .VENDOR:
                    if let _ = DBVendor.instance.get(name: name) {
                        state = false
                    } else {
                        state = true
                    }
                case .TAG:
                    if let _ = DBTag.instance.get(name: name) {
                        state = false
                    } else {
                        state = true
                    }
                default:
                    break
                }
            }
        }

        if (name.count <= 1) {
            okButton.isEnabled = false
        } else {
            okButton.isEnabled = state || optionalSwitchOrig != optionalSwitch.isOn || payerSwitchOrig != payerSwitch.isOn
        }
    }

    func optionalSwitchClick() {
        if createType == .ACCOUNT || createType == .ACCOUNT2 {
            account!.showBalance = optionalSwitch.isOn
        } else {
            if optionalSwitch.isOn {
                if payerSwitch.isOn {
                    vendor!.type = .PAYEE_PAYER
                } else {
                    vendor!.type = .PAYEE
                }
            } else {
                vendor!.type = .PAYER
                payerSwitch.isOn = true
            }
        }
        checkOkButtonState()
    }

    func payerSwitchClick() {
        if payerSwitch.isOn {
            if optionalSwitch.isOn {
                vendor!.type = .PAYEE_PAYER
            } else {
                vendor!.type = .PAYER
            }
        } else {
            vendor!.type = .PAYEE
            optionalSwitch.isOn = true
        }
        checkOkButtonState()
    }

    @IBAction func onOptionalSwitchClick(_ sender: Any) {
        optionalSwitchClick()
    }

    @IBAction func onPayerSwitchClick(_ sender: Any) {
        payerSwitchClick()
    }

    @objc func optionalLabelTapped() {
        optionalSwitch.isOn = !optionalSwitch.isOn
        optionalSwitchClick()
    }

    @objc func payerLabelTapped() {
        payerSwitch.isOn = !payerSwitch.isOn
        payerSwitchClick()
    }

    @objc func payeeLabelTapped() {
        optionalSwitch.isOn = !optionalSwitch.isOn
        optionalSwitchClick()
    }

    private func setOptionalDisplay() {
        optionalLabel.isUserInteractionEnabled = true
        payerLabel.isUserInteractionEnabled = true
        switch (createType!) {
        case .ACCOUNT: fallthrough
        case .ACCOUNT2:
            let labelTapped = UITapGestureRecognizer(target: self, action: #selector(self.optionalLabelTapped))
            labelTapped.delegate = self
            optionalLabel.addGestureRecognizer(labelTapped)
            optionalLabel.text = NSLocalizedString("Show balance", comment: "")
            payerLabel.isHidden = true
            payerSwitch.isHidden = true
            optionalSwitch.isOn = account!.showBalance

            optionalSwitchOrig = optionalSwitch.isOn
        case .PAYEE: fallthrough
        case .PAYER:
            payerSwitch.isEnabled = false
            optionalSwitch.isEnabled = false
            fallthrough
        case .VENDOR:
            optionalLabel.text = NSLocalizedString("Payee", comment: "")
            payerLabel.text = NSLocalizedString("Payer", comment: "")
            if vendor!.type == .PAYEE {
                payerSwitch.isOn = false
                optionalSwitch.isOn = true
            } else if vendor!.type == .PAYER {
                payerSwitch.isOn = true
                optionalSwitch.isOn = false
            } else {
                payerSwitch.isOn = true
                optionalSwitch.isOn = true
            }
            var vendorLabelTapped = UITapGestureRecognizer(target: self, action: #selector(self.payerLabelTapped))
            vendorLabelTapped.delegate = self
            payerLabel.addGestureRecognizer(vendorLabelTapped)

            vendorLabelTapped = UITapGestureRecognizer(target: self, action: #selector(self.payeeLabelTapped))
            optionalLabel.addGestureRecognizer(vendorLabelTapped)

            optionalSwitchOrig = optionalSwitch.isOn
            payerSwitchOrig = payerSwitch.isOn
        case .TAG: fallthrough
        case .CATEGORY:
            optionalLabel.isHidden = true
            optionalSwitch.isHidden = true
            payerLabel.isHidden = true
            payerSwitch.isHidden = true
        case .TYPE:
            LLog.e("\(self)", "Unexpected: type select in CreateViewController")
        }
    }
}
