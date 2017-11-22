//
//  LoginTimerViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 11/17/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class LoginTimerViewController: UIViewController {
    let TAG = "LoginTimerViewController"

    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var connectingLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var timer: Timer?
    var counter: Double = 15.0

    override func viewDidLoad() {
        super.viewDidLoad()
        okButton.isHidden = true

        activityIndicator.startAnimating()

        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(LoginTimerViewController.updateCountDown), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view.

        LBroadcast.register(LBroadcast.ACTION_LOG_IN, cb: #selector(self.login), listener: self)
        //TODO: pass in user name and pass here, pass in mode (signup vs login) as well
        //if (is login mode) then
        UiRequest.instance.UiLogIn("aa", "aaaa")

        //else (sign up mode)
        //UiRequest.instance.UiSignIn("aa", "aaaa")
    }

    @objc func login(notification: Notification) -> Void {
        LLog.d(TAG, "user logged in")
        //TODO: user successfully logged in, updat GUI (automatically dismiss this popover and update parent view?)
        stopCountDown()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        connectingLabel.text = "Unable to connect. Please try again later."
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
