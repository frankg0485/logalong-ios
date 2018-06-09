//
//  UnshareAccountConfirmViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 5/30/18.
//  Copyright © 2018 Swoag Technology. All rights reserved.
//

import UIKit

class UnshareAccountConfirmViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var unshareCheckbox: LCheckbox!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var unshareMessage: UITextView!
    @IBOutlet weak var checkboxMessage: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = LTheme.Color.default_bgd_color

        self.preferredContentSize.width = LTheme.Dimension.popover_width
        self.preferredContentSize.height = LTheme.Dimension.popover_height_small
        checkboxMessage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(doCheckbox)))
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func doCheckbox() {
        unshareCheckbox.isSelected = !unshareCheckbox.isSelected
        if unshareCheckbox.isSelected {
            okButton.isEnabled = true
        } else {
            okButton.isEnabled = false
        }
    }
    @IBAction func checkboxClicked(_ sender: UIButton) {
        doCheckbox()
    }

    @IBAction func cancelClicked(_ sender: UIButton) {
        exit(false)
    }

    @IBAction func okClicked(_ sender: UIButton) {
        exit(true)
    }

    func exit(_ confirm: Bool) {
        if let parent = presentingViewController as? ShareAccountViewController {
            parent.confirmExit(confirm)
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
