//
//  CreateCategoryViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 8/20/17.
//  Copyright © 2017 Frank Gao. All rights reserved.
//

import UIKit

class CreateCategoryViewController: UIViewController, UITextFieldDelegate {

    var category: String? = ""

    @IBOutlet weak var categoryNameTextField: UITextField!
    
    @IBOutlet weak var okButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        categoryNameTextField.delegate = self

        checkOkButtonState()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkOkButtonState()
    }



    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        category = categoryNameTextField.text!
    }

    func checkOkButtonState() {
        if (categoryNameTextField.text?.isEmpty == true) {
            okButton.isEnabled = false
        } else {
            okButton.isEnabled = true
        }
    }

}
