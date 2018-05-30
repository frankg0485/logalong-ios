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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func checkboxClicked(_ sender: UIButton) {
        unshareCheckbox.isSelected = !unshareCheckbox.isSelected
        if unshareCheckbox.isSelected {
            okButton.isEnabled = true
        } else {
            okButton.isEnabled = false
        }
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
