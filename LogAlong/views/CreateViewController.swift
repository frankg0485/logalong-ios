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
        nameTextField.becomeFirstResponder()

        switch (createType!) {
        case .ACCOUNT: fallthrough
        case .ACCOUNT2:
            newLabel.text = NSLocalizedString("New Account", comment: "")
            nameTextField.placeholder = NSLocalizedString("Account Name", comment: "")
        case .CATEGORY:
            newLabel.text = NSLocalizedString("New Category", comment: "")
            nameTextField.placeholder = NSLocalizedString("Category Name", comment: "")
        default: break
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

        delegate.creationCallback(created: true)
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkOkButtonState()
    }



    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }*/

    func checkOkButtonState() {
        if (nameTextField.text?.isEmpty == true) {
            okButton.isEnabled = false
        } else {
            okButton.isEnabled = true
        }
    }

}
