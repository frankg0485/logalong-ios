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
    @IBOutlet weak var acceptAllView: UIView!
    var checkbox: LCheckbox!
    var accountUserLabelText: String = ""
    var request: LAccountShareRequest?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LTheme.Color.default_bgd_color

        preferredContentSize.width = LTheme.Dimension.popover_width
        preferredContentSize.height = 240

        accountUserLabel.text = accountUserLabelText
        //accountUserLabel.font = UIFont.boldSystemFont(ofSize: 17)
        setupDisplay()
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

    @objc func onClickView(_ sender: UITapGestureRecognizer) {
        if acceptAllView == sender.view {
            checkbox.isSelected = !checkbox.isSelected
        }
    }

    private func setupDisplay() {
        let ROW_H: CGFloat = 50
        let ROW_H2: CGFloat = 35

        let hl3 = HorizontalLayout(height: 30)
        hl3.layoutMargins = UIEdgeInsetsMake(0, 0, ROW_H - ROW_H2, 0)
        checkbox = LCheckbox(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        checkbox.layoutMargins = UIEdgeInsetsMake(0, 6, 0, 0)
        checkbox.isUserInteractionEnabled = false
        checkbox.isSelected = false
        let label0 = UILabel(frame: CGRect(x: 1, y: 0, width: 0, height: ROW_H2))
        label0.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0)
        label0.text = NSLocalizedString("accept all from this user", comment: "")
        label0.textColor = LTheme.Color.light_gray_text_color

        hl3.addSubview(checkbox)
        hl3.addSubview(label0)
        acceptAllView.addSubview(hl3)

        setTapGesture(acceptAllView)
    }

    private func done(_ ok: Bool) {
        if checkbox.isSelected {
            LPreferences.setShareAccept((request?.userId)!, Int64(Date().timeIntervalSince1970))
        }

        if let tabController = presentingViewController as? MainTabViewController {
            if let navigationController = tabController.viewControllers![1] as? UINavigationController {
                //Only mainViewController displays share popup, topViewController can be any
                //view controller(i.e. ScheduleViewController) that's pushed by the main
                //view controller
                if let mainController = navigationController.viewControllers[0] as? MainViewController {
                    mainController.onShareAccountConfirmDialogExit(ok, request!)
                }
            }
        }
    }

    @IBAction func declineButtonClicked(_ sender: UIButton) {
        done(false)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func okButtonClicked(_ sender: UIButton) {
        done(true)
        dismiss(animated: true, completion: nil)
    }
}
