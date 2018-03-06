//
//  CurrentPasswordViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 12/16/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class CurrentPasswordViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var progress: UIActivityIndicatorView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var wrongPasswordLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var showPassView: HorizontalLayout!
    let FONT_H: CGFloat = 20

    var checkboxShowPass: LCheckbox!
    var password: String!

    var timer: Timer?
    var count: Double = 0
    var overlayViewController: UIViewController?

    var passwordChanged = false
    var delegate: FShowPasswordCellsDelegate?
    var signin = false {
        didSet {
            delegate?.showPasswordCells()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize.width = LTheme.Dimension.popover_width
        preferredContentSize.height = LTheme.Dimension.popover_height_small + 20

        cancelButton.isEnabled = true
        okButton.isEnabled = false

        passwordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true
        passwordTextField.font = UIFont.boldSystemFont(ofSize: FONT_H)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        setTapGesture(view)

        LBroadcast.register(LBroadcast.ACTION_SIGN_IN, cb: #selector(self.signIn), listener: self)

        // Do any additional setup after loading the view.
        setupDisplay()
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

    private func setupDisplay() {
        let ROW_H: CGFloat = 50
        let ROW_H2: CGFloat = 35

        if let hl3 = showPassView {
            hl3.layoutMargins = UIEdgeInsetsMake(0, 0, ROW_H - ROW_H2, 0)
            checkboxShowPass = LCheckbox(frame: CGRect(x: 0, y: 0, width: 40, height: ROW_H2))
            checkboxShowPass.layoutMargins = UIEdgeInsetsMake(0, 6, 0, 0)
            checkboxShowPass.isUserInteractionEnabled = false
            checkboxShowPass.isSelected = false
            let label0 = UILabel(frame: CGRect(x: 1, y: 0, width: 0, height: ROW_H2))
            label0.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0)
            label0.text = NSLocalizedString("show password", comment: "")
            label0.textColor = LTheme.Color.light_gray_text_color
            showPassView = hl3

            hl3.addSubview(checkboxShowPass)
            hl3.addSubview(label0)
        }

        setTapGesture(showPassView)
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
        startTimer(5)
        _ = UiRequest.instance.UiSignIn(LPreferences.getUserId(), password)
    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        LBroadcast.unregister(LBroadcast.ACTION_SIGN_IN, listener: self)
        dismiss(animated: true, completion: nil)
    }

    @objc func signIn(notification: Notification) -> Void {
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
            delegate?.showPasswordCells()
            wrongPasswordLabel.text = ""

            cancelButtonPressed(cancelButton)
        } else {
            wrongPasswordLabel.text = NSLocalizedString("Password mismatch", comment: "")
        }
    }

    private func setDoneButtonState() {
        if password.isEmpty {
            okButton.isEnabled = false
        } else{
            okButton.isEnabled = password.count > 3
        }
    }

    private func readTextField(_ textField: UITextField) {
        if let txt = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            passwordTextField.text = txt
            password = txt
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let limitLength = 20
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
