//
//  DatePickerViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 9/29/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController {

    var delegate: FViewControllerDelegate?
    var type: TypePassed = TypePassed(double: 0, int: 0, int64: 0)

    @IBOutlet weak var datePicker: UIDatePicker!

    var initValue: Int64 = 0
    var color: UIColor!

    override func viewDidLoad() {
        super.viewDidLoad()

        datePicker.datePickerMode = .date
        datePicker.date = Date(milliseconds: initValue)
    }

    override func viewWillAppear(_ animated: Bool) {
        view.superview?.layer.borderColor = color.cgColor
        view.superview?.layer.borderWidth = 1
        super.viewWillAppear(animated)
    }

    @IBAction func okButtonPressed(_ sender: UIButton) {
        type.int64 = datePicker.date.currentTimeMillis
        delegate?.passNumberBack(self, type: type)

        dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
