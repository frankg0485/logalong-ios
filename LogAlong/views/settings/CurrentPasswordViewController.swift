//
//  CurrentPasswordViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 12/16/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class CurrentPasswordViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var progress: UIActivityIndicatorView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var wrongPasswordLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var showPassView: HorizontalLayout!
    let FONT_H: CGFloat = 20

    var checkboxShowPass: LCheckbox!
    var password: String!

    var resetPassword = false
    var canCancel = true
    var emailSent = false

    var timer: Timer?
    var count: Double = 0
    var overlayViewController: UIViewController?

    var passwordChanged = false
    var delegate: FShowPasswordCellsDelegate?
    var alreadyDismissed = false

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = LTheme.Color.default_bgd_color

        preferredContentSize.width = LTheme.Dimension.popover_width
        preferredContentSize.height = LTheme.Dimension.popover_height_small + 20

        cancelButton.isEnabled = canCancel
        okButton.isEnabled = false

        passwordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true
        passwordTextField.font = UIFont.boldSystemFont(ofSize: FONT_H)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        setTapGesture(view)

        LBroadcast.register(LBroadcast.ACTION_SIGN_IN, cb: #selector(self.signIn), listener: self)
        LBroadcast.register(LBroadcast.ACTION_UI_RESET_PASSWORD, cb: #selector(self.uiResetPassword), listener: self)

        // Do any additional setup after loading the view.
        setupDisplay()
        setupResetPasswordDisplay()
        progress.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setTapGesture(_ view: UIView) {
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onClickView(_:)))
        view.addGestureRecognizer(tapGesture)
    }

    private func setupResetPasswordDisplay() {
        resetButton.isHidden = true
        wrongPasswordLabel.text = ""
        if resetPassword {
            okButton.isEnabled = false
            showPassView.isHidden = true
            passwordTextField.text = ""
            passwordTextField.isSecureTextEntry = false
            passwordTextField.placeholder = NSLocalizedString("email address", comment:"")
            headerLabel.text = NSLocalizedString("Enter email to reset password", comment: "")
        } else {
            showPassView.isHidden = false
            passwordTextField.text = ""
            passwordTextField.placeholder =  NSLocalizedString("password", comment: "")
            headerLabel.text = NSLocalizedString("Enter current password", comment: "")
        }
    }

    private func setupDisplay() {
        let ROW_H: CGFloat = 50
        let ROW_H2: CGFloat = 35

        if let hl3 = showPassView {
            hl3.layoutMargins = UIEdgeInsetsMake(0, 0, ROW_H - ROW_H2, 0)
            checkboxShowPass = LCheckbox(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            checkboxShowPass.layoutMargins = UIEdgeInsetsMake(0, 6, 0, 0)
            checkboxShowPass.isUserInteractionEnabled = false
            checkboxShowPass.isSelected = false
            let label0 = UILabel(frame: CGRect(x: 1, y: 0, width: 0, height: ROW_H2))
            label0.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0)
            label0.text = NSLocalizedString("show password", comment: "")
            label0.textColor = LTheme.Color.light_gray_text_color

            hl3.addSubview(checkboxShowPass)
            hl3.addSubview(label0)
        }

        setTapGesture(showPassView)
    }

    @IBAction func onResetClick(_ sender: UIButton) {
        resetPassword = true
        setupResetPasswordDisplay()
    }

    @objc func timerHandler() {
        stopTimer()
        wrongPasswordLabel.text = NSLocalizedString("Unable to connect to server. Please try again later.", comment: "")
    }

    private func resetTimer(_ interval: Double) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timerHandler), userInfo: nil, repeats: false)
    }

    private func startTimer(_ interval: Double) {
        resetTimer(interval)
        wrongPasswordLabel.text = ""

        progress.isHidden = false
        progress.startAnimating()

        overlayViewController = UIViewController()
        overlayViewController!.modalPresentationStyle = .overCurrentContext
        overlayViewController!.view.backgroundColor = .clear
        overlayViewController!.view.isOpaque = false
        self.present(overlayViewController!, animated: false, completion: nil)
    }

    private func stopTimer() {
        progress.stopAnimating()
        progress.isHidden = true
        timer?.invalidate()
        overlayViewController?.dismiss(animated: false, completion: nil)
    }

    @objc func onClickView(_ sender: UITapGestureRecognizer) {
        passwordTextField.resignFirstResponder()

        if showPassView == sender.view {
            checkboxShowPass.isSelected = !checkboxShowPass.isSelected
            passwordTextField.isSecureTextEntry = !checkboxShowPass.isSelected
        }
    }

    @IBAction func okButtonPressed(_ sender: UIButton) {
        if alreadyDismissed {
            do_cancel() //JIC
            return
        }

        if emailSent {
            resetPassword = false
            emailSent = false
            setupResetPasswordDisplay()
        } else {
            if resetPassword {
                startTimer(LServer.REQUEST_TIMEOUT_SECONDS * 2)
                _ = UiRequest.instance.UiResetPassword(LPreferences.getUserId(), email: password)
            } else {
                startTimer(LServer.REQUEST_TIMEOUT_SECONDS)
                _ = UiRequest.instance.UiSignIn(LPreferences.getUserId(), password)
            }
        }
    }

    private func do_cancel() {
        LBroadcast.unregister(LBroadcast.ACTION_SIGN_IN, listener: self)
        LBroadcast.unregister(LBroadcast.ACTION_UI_RESET_PASSWORD, listener: self)
        dismiss(animated: true, completion: nil)

        //FIXME: for unknown reason (maybe this is a simulator only behaviour, but sometime it would complain
        // "Warning: Attempt to dismiss from view controller ... while a presentation or dismiss is in progress!"
        // and if that happens, this popover will fail to dismiss, and causes subsequent 'OK' click to error out
        alreadyDismissed = true
    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        do_cancel()
    }

    @objc func signIn(notification: Notification) -> Void {
        stopTimer()

        var success = false
        if let bdata = notification.userInfo as? [String: Any] {
            if let status = bdata["status"] as? Int {
                if LProtocol.RSPS_OK == status {
                    success = true
                    LPreferences.setUserPassword(password)
                    _ = UiRequest.instance.UiLogIn(LPreferences.getUserId(), password)
                }
            }
        }

        if success {
            delegate?.showPasswordCells()
            wrongPasswordLabel.text = ""
            DispatchQueue.main.async {
                self.do_cancel()
            }
        } else {
            wrongPasswordLabel.text = NSLocalizedString("Password mismatch", comment: "")
            resetButton.isHidden = false
        }
    }

    @objc func uiResetPassword(notification: Notification) -> Void {
        stopTimer()

        var success = false
        if let bdata = notification.userInfo as? [String: Any] {
            if let status = bdata["status"] as? Int {
                if LProtocol.RSPS_OK == status {
                    success = true
                }
            }
        }

        if success {
            wrongPasswordLabel.text = "Please follow instructions in email to reset password."
            emailSent = true
        } else {
            wrongPasswordLabel.text = "Unable to email notification, please try later"
        }
    }

    private func isValidEmail(_ testStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

    private func setDoneButtonState() {
        if password.isEmpty {
            okButton.isEnabled = false
        } else{
            if resetPassword {
                okButton.isEnabled = isValidEmail(password)
            } else {
                okButton.isEnabled = password.count > 3
            }
        }
    }

    private func readTextField(_ textField: UITextField) {
        if let txt = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            passwordTextField.text = txt
            password = txt
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let limitLength = resetPassword ? 36 : 20
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= limitLength
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        readTextField(textField)
        setDoneButtonState()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        readTextField(textField)
        setDoneButtonState()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
