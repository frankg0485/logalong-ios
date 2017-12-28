//
//  CurrentPasswordViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 12/16/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class CurrentPasswordViewController: UIViewController, UITextFieldDelegate, FNotifyShowPasswordDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var wrongPasswordLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!

    var passwordChanged = false
    var delegate: FShowPasswordCellsDelegate?
    var signin = false {
        didSet {
            delegate?.showPasswordCells()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if presentingViewController is MainTabViewController {
            passwordChanged = true

            cancelButton.isEnabled = false
        }

        wrongPasswordLabel.isHidden = true

        passwordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true

        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(screenTapped(_:)))

        view.addGestureRecognizer(tapGestureRecognizer)

        LBroadcast.register(LBroadcast.ACTION_SIGN_IN, cb: #selector(self.signIn), listener: self)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func switchSwitched(_ sender: UISwitch) {
        if sender.isOn {
            passwordTextField.isSecureTextEntry = false
        } else {
            passwordTextField.isSecureTextEntry = true
        }
    }

    @objc func screenTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        passwordTextField.resignFirstResponder()
    }

    @IBAction func okButtonPressed(_ sender: UIButton) {
        UiRequest.instance.UiSignIn(LPreferences.getUserId(), passwordTextField.text!)
    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @objc func signIn(notification: Notification) -> Void {
        if let bdata = notification.userInfo as? [String: Any] {
            if let status = bdata["status"] as? Int {
                if LProtocol.RSPS_OK == status {
                    signin = true

                    if passwordChanged {
                        LPreferences.setUserPassword(passwordTextField.text!)
                    }
                }
            }
        }

        if !signin {
            wrongPasswordLabel.isHidden = false
        } else {
            dismiss(animated: true, completion: nil)
        }
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }*/


}
