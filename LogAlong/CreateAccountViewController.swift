//
//  CreateAccountViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 8/15/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController, UITextFieldDelegate {

    var account: Account?

    @IBOutlet weak var accountNameTextField: UITextField!

    @IBOutlet weak var okButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        accountNameTextField.delegate = self

        if let account = account {
            accountNameTextField.text = account.name
        }


        checkOkButtonState()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        account = Account(id: 0, name: accountNameTextField.text!)
    }

    func checkOkButtonState() {
        if (accountNameTextField.text?.isEmpty == true) {
            okButton.isEnabled = false
        } else {
            okButton.isEnabled = true
        }
    }

}
