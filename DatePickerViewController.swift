//
//  DatePickerViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 9/29/17.
//  Copyright © 2017 Frank Gao. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController {

    var delegate: FViewControllerDelegate?
    var type: TypePassed = TypePassed(double: 0, int: 0, int64: 0)

    @IBOutlet weak var datePicker: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()

        datePicker.datePickerMode = .date

        // Do any additional setup after loading the view.
    }


    @IBAction func okButtonPressed(_ sender: UIButton) {

        type.double = datePicker.date.timeIntervalSince1970.rounded()

        delegate?.passNumberBack(self, type: type)

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
