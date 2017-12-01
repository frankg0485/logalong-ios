//
//  LoginTimerViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 11/17/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

enum typeOfLogin: Int {
    case CREATE = 0
    case LOGIN = 1
}

class LoginTimerViewController: UIViewController {
    let TAG = "LoginTimerViewController"

    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var connectingLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var timer: Timer?
    var counter: Double = 15.0

    //TODO: caller must make sure name/userId/password are valid: for example no leading/trailing
    //      spaces are allowed for password/userId/name, no spaces are allowed for userId, all with
    //      length restrictions etc
    var name: String? = ""
    var userId: String = ""
    var password: String = ""
    var loginType: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        okButton.isHidden = true

        activityIndicator.startAnimating()

        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(LoginTimerViewController.updateCountDown), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view.

        LBroadcast.register(LBroadcast.ACTION_CREATE_USER, cb: #selector(self.createUser), listener: self)
        LBroadcast.register(LBroadcast.ACTION_SIGN_IN, cb: #selector(self.signin), listener: self)
        LBroadcast.register(LBroadcast.ACTION_LOG_IN, cb: #selector(self.login), listener: self)

        if typeOfLogin.LOGIN.rawValue == loginType {
            UiRequest.instance.UiSignIn(userId, password )
        } else if LPreferences.getUserId().isEmpty {
            UiRequest.instance.UiCreateUser(userId, password, fullname: name!)
        } else {
            LLog.e(TAG, "unexpected state, requested to recreate user");
        }
    }

    @objc func createUser(notification: Notification) -> Void {
        var success = false
        if let bdata = notification.userInfo as? [String: Any] {
            if let status = bdata["status"] as? Int {
                if LProtocol.RSPS_OK == status {
                    LPreferences.setUserId(userId)
                    LPreferences.setUserPassword(password)
                    LPreferences.setUserName(name!)

                    UiRequest.instance.UiLogIn(userId, password)
                    //TODO: push local database

                    success = true;
                }
            }
        }

        if success {
            LLog.d(TAG, "user created")
        } else {
            LLog.d(TAG, "failed to create user")
            //TODO: update GUI to report error
        }
        stopCountDown()
    }

    @objc func signin(notification: Notification) -> Void {
        var success = false
        if let bdata = notification.userInfo as? [String: Any] {
            if let status = bdata["status"] as? Int {
                if LProtocol.RSPS_OK == status {
                    LPreferences.setUserId(userId)
                    LPreferences.setUserPassword(password)
                    if let name = bdata["name"] as? String {
                        LPreferences.setUserName(name)
                    }

                    UiRequest.instance.UiLogIn(userId, password)
                    //TODO: push local database

                    success = true;
                }
            }
        }

        if success {
            LLog.d(TAG, "user signed in")
        } else {
            LLog.d(TAG, "user failed to sign in")
            //TODO: update GUI to report error
        }
    }

    @objc func login(notification: Notification) -> Void {
        var success = false
        if let bdata = notification.userInfo as? [String: Any] {
            if let status = bdata["status"] as? Int {
                if LProtocol.RSPS_OK == status {
                    success = true
                }
            }
        }

        if success {
            LLog.d(TAG, "user logged in")
            connectingLabel.text = "Login Successful"

        } else {
            LLog.d(TAG, "user failed to login")
            connectingLabel.text = "Unable to connect. Please try again later."

        }
    }

    @IBAction func okButtonClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @objc func updateCountDown() {
        if (counter > 0) {
            counter = counter - 0.05
        } else {
            stopCountDown()
        }
    }

    func stopCountDown() {
        okButton.isHidden = false

        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true

        timer?.invalidate()
        timer = nil
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
