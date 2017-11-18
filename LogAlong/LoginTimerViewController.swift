//
//  LoginTimerViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 11/17/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class LoginTimerViewController: UIViewController {

    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var connectingLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!

    var timer: Timer?
    var counter: Double = 15.0

    override func viewDidLoad() {
        super.viewDidLoad()
        okButton.isHidden = true

        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(LoginTimerViewController.updateCountDown), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view.
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
            progressView.progress += (0.05/15)
        } else {
            stopCountDown()
        }
    }

    func stopCountDown() {
        connectingLabel.text = "Unable to connect. Please try again later."
        okButton.isHidden = false
        progressView.isHidden = true

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
