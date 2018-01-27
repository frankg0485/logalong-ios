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

class CreateViewController: UIViewController, UITextFieldDelegate {

    //var creation: NameWithId? = NameWithId(name: "", id: 0)
    var delegate: FPassCreationBackDelegate!
    var createType: SelectType!

    @IBOutlet weak var newLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var okButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize.width = LTheme.Dimension.popover_width
        self.preferredContentSize.height = LTheme.Dimension.popover_height_small

        nameTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        nameTextField.becomeFirstResponder()

        switch (createType!) {
        case .ACCOUNT: fallthrough
        case .ACCOUNT2:
            newLabel.text = NSLocalizedString("New Account", comment: "")
            nameTextField.placeholder = NSLocalizedString("Name", comment: "")
        case .CATEGORY:
            newLabel.text = NSLocalizedString("New Category", comment: "")
            nameTextField.placeholder = NSLocalizedString("Category : Sub-category", comment: "")
        case .PAYEE:
            newLabel.text = NSLocalizedString("New Payer/Payee", comment: "")
            nameTextField.placeholder = NSLocalizedString("Name", comment: "")
        case .PAYER:
            newLabel.text = NSLocalizedString("New Payer/Payee", comment: "")
            nameTextField.placeholder = NSLocalizedString("Name", comment: "")
        case .VENDOR:
            newLabel.text = NSLocalizedString("New Payer/Payee", comment: "")
            nameTextField.placeholder = NSLocalizedString("Name", comment: "")
        case .TAG:
            newLabel.text = NSLocalizedString("New Tag", comment: "")
            nameTextField.placeholder = NSLocalizedString("Name", comment: "")
        }

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
        if let name = nameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
            switch (createType!) {
            case .ACCOUNT: fallthrough
            case .ACCOUNT2:
                var account = LAccount(name: name)
                if DBAccount.instance.add(&account) {
                    _ = LJournal.instance.addAccount(account.id)
                }
            case .CATEGORY:
                var category = LCategory(name: name)
                if DBCategory.instance.add(&category) {
                    _ = LJournal.instance.addCategory(category.id)
                }
            case .PAYER: fallthrough
            case .PAYEE: fallthrough
            case .VENDOR:
                var vendor = LVendor(name: name)
                if DBVendor.instance.add(&vendor) {
                    _ = LJournal.instance.addVendor(vendor.id)
                }
            case .TAG:
                var tag = LTag(name: name)
                if DBTag.instance.add(&tag) {
                    _ = LJournal.instance.addTag(tag.id)
                }
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

    func checkOkButtonState() {
        var state = false
        if let name = nameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
            if !name.isEmpty && name.count > 1 {
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
        okButton.isEnabled = state
    }
}
