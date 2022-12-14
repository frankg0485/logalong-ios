//
//  ProfileReminderViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 3/22/18.
//  Copyright © 2018 Swoag Technology. All rights reserved.
//

import UIKit

class ProfileReminderViewController: UIViewController {
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var reminderTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = LTheme.Color.default_bgd_color
        reminderTextView.backgroundColor = LTheme.Color.default_bgd_color

        self.preferredContentSize.height = LTheme.Dimension.popover_height_small
        self.preferredContentSize.width = LTheme.Dimension.popover_width
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func okButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
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
