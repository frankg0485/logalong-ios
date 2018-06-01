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
    var type: TypePassed = TypePassed(double: 0, int: 0, int64: 0, array64: nil, allSelected: false)

    @IBOutlet weak var datePicker: UIDatePicker!

    var initValue: Int64 = 0
    var color: UIColor!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = LTheme.Color.default_bgd_color
        datePicker.backgroundColor = LTheme.Color.default_bgd_color

        self.preferredContentSize.width = LTheme.Dimension.popover_width
        self.preferredContentSize.height = LTheme.Dimension.popover_height_small

        datePicker.datePickerMode = .date
        datePicker.date = Date(milliseconds: initValue)
    }

    override func viewWillAppear(_ animated: Bool) {
        view.superview?.layer.borderColor = color.cgColor
        view.superview?.layer.borderWidth = 1
        super.viewWillAppear(animated)
    }

    func getDate() -> Int64 {
        let pickerComponents = LA.ymd(date: datePicker.date)

        var dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: Date())
        dateComponents.year = pickerComponents.year
        dateComponents.month = pickerComponents.month + 1
        dateComponents.day = pickerComponents.day

        return (Calendar.current.date(from: dateComponents)?.currentTimeMillis)!
    }

    @IBAction func okButtonPressed(_ sender: UIButton) {
        type.int64 = getDate()
        delegate?.passNumberBack(self, type: type, okPressed: true)

        dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
