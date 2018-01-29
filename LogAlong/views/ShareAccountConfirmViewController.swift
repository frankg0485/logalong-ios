//
//  ShareAccountConfirmViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 1/28/18.
//  Copyright © 2018 Swoag Technology. All rights reserved.
//

import UIKit

class ShareAccountConfirmViewController: UIViewController {
    @IBOutlet weak var accountUserLabel: UILabel!
    @IBOutlet weak var acceptAllButton: UIButton!

    var accountUserLabelText: String = ""
    var checked = false
    var request: LAccountShareRequest?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = LTheme.Color.dialog_bg_color
        accountUserLabel.text = accountUserLabelText
        accountUserLabel.font = UIFont.boldSystemFont(ofSize: 17)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func exit(_ ok: Bool) {
        if checked {
            LPreferences.setShareAccept((request?.userId)!, Int64(Date().timeIntervalSince1970))
        }

        if let tabController = presentingViewController as? MainTabViewController {
            if let navigationController = tabController.viewControllers![1] as? UINavigationController {
                if let mainController = navigationController.topViewController as? MainViewController {
                    mainController.onShareAccountConfirmDialogExit(ok, request!)
                }
            }
        }
    }

    @IBAction func declineButtonClicked(_ sender: UIButton) {
        exit(false)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func okButtonClicked(_ sender: UIButton) {
        exit(true)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func acceptAllButtonClicked(_ sender: UIButton) {
        if checked {
            checked = false
            sender.setImage(#imageLiteral(resourceName: "btn_check_off_normal_holo_light").withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            checked = true
            sender.setImage(#imageLiteral(resourceName: "btn_check_on_holo_light").withRenderingMode(.alwaysOriginal), for: .normal)
        }
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
