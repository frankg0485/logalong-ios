//
//  CurrentPasswordViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 12/16/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class CurrentPasswordViewController: UIViewController, UITextFieldDelegate, FNotifyShowPasswordDelegate {

    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showPassword(show: Bool) {
        if show {
            passwordTextField.isSecureTextEntry = false
        } else {
            passwordTextField.isSecureTextEntry = true
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if UiRequest.instance.UiSignIn(LPreferences.getUserName(), textField.text!) {

        } else {

        }
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let secondViewController = segue.destination as? ShowPasswordTableViewController {
            secondViewController.delegate = self
        }
    }


}
